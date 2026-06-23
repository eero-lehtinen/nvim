---@type table<string, integer> path -> bufnr
local pending_format = {}
---@type table<string, integer> path -> bufnr
local pending_save = {}
---@type table<integer, string> bufnr -> pre-edit file content
local pre_edit_bases = {}
---@type table<string, boolean> path -> existed before agent edit
local pre_edit_missing = {}
---@type table<integer, string> bufnr -> content at the last buffer/disk sync
-- The true common ancestor for the next 3-way merge. A 3-way merge is only
-- correct when its base is the version `ours` (buffer) and `theirs` (disk) last
-- agreed on; reading disk at pre-edit time is wrong once the buffer has drifted.
local synced_content = {}

-- Don't snapshot bases for large files; the table is held in memory for the
-- whole session and big/binary buffers aren't worth merging line-wise anyway.
local MAX_SYNC_BYTES = 1024 * 1024

-- Whether a buffer is worth tracking a merge base for: a real, loaded, normal
-- text file under the size cap. Excludes special buffers (terminals, help,
-- nofile), binary buffers, and anything large.
---@param bufnr integer
---@return boolean
local function trackable(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return false
  end
  if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].binary then
    return false
  end
  -- Byte size = offset just past the last line (cheap; no string built).
  local size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
  return size >= 0 and size <= MAX_SYNC_BYTES
end

-- Reconstruct the buffer's on-disk byte form, so it is comparable to a base
-- captured the same way (matters for CRLF/`fileformat`).
---@param bufnr integer
---@return string
local function buffer_text(bufnr)
  local ff = vim.bo[bufnr].fileformat
  local eol = ff == "dos" and "\r\n" or ff == "mac" and "\r" or "\n"
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), eol) .. eol
end

---@type integer
local group = vim.api.nvim_create_augroup("AgentPostEdit", { clear = true })
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = group,
  callback = function(ev)
    if pre_edit_bases[ev.buf] ~= nil then
      vim.v.fcs_choice = ""
    end
  end,
})
-- After a load or save, buffer == disk: record that as the merge ancestor
-- (only for normal text files under the size cap).
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = group,
  callback = function(ev)
    synced_content[ev.buf] = trackable(ev.buf) and buffer_text(ev.buf) or nil
  end,
})
vim.api.nvim_create_autocmd("BufDelete", {
  group = group,
  callback = function(ev)
    synced_content[ev.buf] = nil
    pre_edit_bases[ev.buf] = nil
  end,
})

---@param input_path string
---@return string path  Path relative to cwd if inside cwd, otherwise absolute
---@return boolean in_cwd
local function normalize_path(input_path)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local path = vim.fs.normalize(vim.fn.fnamemodify(input_path:gsub("\r", ""), ":p"))
  local in_cwd = vim.startswith(path, cwd)
  if in_cwd then
    path = path:sub(#cwd + 2)
  end
  return path, in_cwd
end

---@param content string
---@return string? path  Tempfile path on success, nil on error
---@return string? err
local function write_temp(content)
  local f = vim.fn.tempname()
  local fd, err = vim.uv.fs_open(f, "w", 438)
  if not fd then
    return nil, err
  end
  local _, werr = vim.uv.fs_write(fd, content)
  vim.uv.fs_close(fd)
  if werr then
    vim.uv.fs_unlink(f)
    return nil, werr
  end
  return f
end

-- 3-way merge: buffer (ours) + disk (theirs) over the last buffer/disk sync as
-- base. A clean merge is applied; a conflicting one keeps the agent's (disk)
-- version and warns, rather than silently interleaving both sides.
---@param path string
---@param bufnr integer
---@return boolean success
local function try_merge_buffer(path, bufnr)
  -- Prefer the tracked common ancestor; fall back to the pre-edit disk
  -- snapshot, then git HEAD. The tracked base is the only one that stays
  -- correct after the buffer has diverged from disk.
  local base = synced_content[bufnr] or pre_edit_bases[bufnr]
  pre_edit_bases[bufnr] = nil
  if not base then
    local result = vim.system({ "git", "show", "HEAD:" .. path }):wait()
    if result.code ~= 0 then
      return false
    end
    base = result.stdout
  end
  if not base then
    return false
  end

  local ours_f, ours_err = write_temp(buffer_text(bufnr))
  if not ours_f then
    vim.notify("agent merge: " .. ours_err, vim.log.levels.WARN)
    return false
  end
  local base_f, base_err = write_temp(base)
  if not base_f then
    vim.uv.fs_unlink(ours_f)
    vim.notify("agent merge: " .. base_err, vim.log.levels.WARN)
    return false
  end

  local view
  if vim.api.nvim_get_current_buf() == bufnr then
    view = vim.fn.winsaveview()
  end

  -- Merge ours (buffer/user edits) + base (last sync) + theirs (disk/agent).
  -- No --ours/--theirs: the exit code is the conflict count, so we can tell a
  -- clean merge from one git could only resolve by guessing.
  local merge_result =
    vim.system({ "git", "merge-file", "--diff-algorithm=histogram", ours_f, base_f, path }):wait()
  vim.uv.fs_unlink(base_f)

  if merge_result.code < 0 then
    vim.uv.fs_unlink(ours_f)
    vim.notify("agent merge: git merge-file failed", vim.log.levels.WARN)
    if view then
      vim.fn.winrestview(view)
    end
    return false
  end

  local merged
  if merge_result.code > 0 then
    -- Concurrent user edits could not be auto-merged. Don't push conflict
    -- markers into a buffer that's about to be formatted and saved; take the
    -- agent's version and surface it loudly so the user can recover via undo.
    merged = vim.fn.readfile(path)
    vim.notify(
      ("agent merge: conflicting edits in %s — kept the agent's version; your buffer changes are in undo history"):format(
        path
      ),
      vim.log.levels.WARN
    )
  else
    merged = vim.fn.readfile(ours_f)
  end
  vim.uv.fs_unlink(ours_f)

  -- Apply only the lines that differ, to preserve marks/extmarks/folds.
  local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local hunks = vim.text.diff(
    table.concat(current_lines, "\n") .. "\n",
    table.concat(merged, "\n") .. "\n",
    { result_type = "indices", algorithm = "histogram" }
  )
  -- Apply in reverse so earlier line numbers stay valid.
  for i = #hunks, 1, -1 do
    ---@diagnostic disable-next-line: need-check-nil
    local sa, ca, sb, cb = hunks[i][1], hunks[i][2], hunks[i][3], hunks[i][4]
    -- For an insertion (ca == 0), start_a is the line to insert *after*, so the
    -- 0-based row is `sa`; for a replace/delete it is `sa - 1`. Using `sa - 1`
    -- for both places insertions one line too early (and a top insert, sa == 0,
    -- at the buffer end via row -1) — the source of the scrambled merges.
    local start = ca == 0 and sa or sa - 1
    vim.api.nvim_buf_set_lines(bufnr, start, start + ca, false, vim.list_slice(merged, sb, sb + cb - 1))
  end

  -- The buffer now holds the merged content; it becomes the ancestor for the
  -- next merge (and matches disk once the pending write/format runs).
  synced_content[bufnr] = trackable(bufnr) and buffer_text(bufnr) or nil

  -- Update mtime to make checktime believe that we are up to date with the file
  vim.b[bufnr].orig_mtime = vim.uv.fs_stat(path).mtime.sec
  vim.bo[bufnr].modified = false

  if view then
    vim.fn.winrestview(view)
  end
  return true
end

---@param path string
---@param bufnr integer
---@param on_done fun()  Invoked once formatting and the follow-up write finish
local function format_file(path, bufnr, on_done)
  if not vim.uv.fs_stat(path) then
    on_done()
    return
  end

  require("conform").format({
    bufnr = bufnr,
    async = true,
  }, function(_, _)
    -- Current buf gets saved by us
    if bufnr ~= vim.api.nvim_get_current_buf() then
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent! write!")
      end)
    end
    on_done()
  end)
end

---@param path string
---@param change_type integer 1 = created, 2 = changed, 3 = deleted
local function notify_lsp_file_changed(path, change_type)
  local abs = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  local uri = vim.uri_from_fname(abs)

  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method("workspace/didChangeWatchedFiles") then
      local root = client.config.root_dir or client.root_dir
      root = root and vim.fs.normalize(root)

      if not root or vim.startswith(abs, root) then
        client:notify("workspace/didChangeWatchedFiles", {
          changes = {
            {
              uri = uri,
              type = change_type,
            },
          },
        })
      end
    end
  end
end

-- Called before an AI agent edits a file. Saves the pre-edit state as merge base.
---@param input_paths string|string[]
---@return string
function _G.agent_pre_edit(input_paths)
  if type(input_paths) == "string" then
    input_paths = { input_paths }
  end
  for _, input_path in ipairs(input_paths) do
    local path = normalize_path(input_path)
    local stat = vim.uv.fs_stat(path)
    if not stat then
      pre_edit_missing[path] = true
    else
      local fd = vim.uv.fs_open(path, "r", 438)
      if fd then
        local bufnr = vim.fn.bufadd(path)
        vim.bo[bufnr].buflisted = true
        pre_edit_bases[bufnr] = vim.uv.fs_read(fd, stat.size)
        vim.uv.fs_close(fd)
      end
    end
  end
  return ""
end

-- Called by AI coding agents after editing a file. Syncs the buffer and queues formatting.
---@param input_paths string|string[]
---@return string
function _G.agent_post_edit(input_paths)
  if type(input_paths) == "string" then
    input_paths = { input_paths }
  end

  local done = false
  vim.schedule(function()
    for _, input_path in ipairs(input_paths) do
      local path, in_cwd = normalize_path(input_path)
      local change_type = pre_edit_missing[path] and 1 or 2
      pre_edit_missing[path] = nil

      local bufnr = vim.fn.bufadd(path)
      vim.bo[bufnr].buflisted = true
      vim.fn.bufload(bufnr)

      if not vim.bo[bufnr].modified or not try_merge_buffer(path, bufnr) then
        vim.bo[bufnr].modified = false
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent! edit!")
        end)
      end

      notify_lsp_file_changed(path, change_type)

      if in_cwd then
        pending_format[path] = bufnr
      else
        pending_save[path] = bufnr
      end
    end
    done = true
  end)

  vim.wait(4000, function()
    return done
  end, 5)
  return ""
end

-- Called when an AI agent finishes its turn. Formats all pending files.
---@return string
function _G.agent_stop()
  vim.schedule(function()
    for path, bufnr in pairs(pending_format) do
      format_file(path, bufnr, function()
        pending_format[path] = nil
      end)
    end
    for path, bufnr in pairs(pending_save) do
      if vim.uv.fs_stat(path) then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent! write!")
        end)
      end
      pending_save[path] = nil
    end
  end)

  vim.wait(9000, function()
    return next(pending_format) == nil and next(pending_save) == nil
  end, 10)
  return ""
end

local function claude_focus_terminal()
  local snacks = require("snacks")
  for _, term in pairs(snacks.terminal.list()) do
    ---@diagnostic disable-next-line: undefined-field
    if type(term.cmd) == "string" and term.cmd:find("claude") then
      term:show()
      term:focus()
      vim.cmd("startinsert")
      return
    end
  end
end

return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    init = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            -- next = "<C-¨>", -- actually <C-]>
            -- prev = "<C-å>", -- actually <C-[>
            -- dismiss = "<C-ä>", -- below [
            -- accept = "<C-a>",
            -- accept = "<C-u>", -- Next to C-y which is normal complete

            next = "<M-n>",
            prev = "<M-p>",
            accept = "<F24>",
            dismiss = "<M-e>",
          },
        },
        filetypes = {
          ["*"] = true,
        },
        -- copilot_model = "gpt-4o-copilot", -- just use the default model
        server = {
          -- type = "binary",
        },
      })

      -- require("copilot.command").disable()
      local enabled = true

      vim.keymap.set("n", "<leader>ta", function()
        require("copilot.command").toggle()
        enabled = not enabled
        if enabled then
          vim.notify("Copilot enabled")
        else
          vim.notify("Copilot disabled")
        end
      end, { desc = "[T]oggle [A]I Copilot" })

      vim.keymap.set("i", "<C-u>", function()
        if require("copilot.suggestion").has_next() then
          require("copilot.suggestion").accept()
        end
      end, { desc = "Accept Copilot Suggestion" })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })

      local function set_copilot_hl()
        vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#739296" })
      end
      set_copilot_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("CopilotHighlight", { clear = true }),
        callback = set_copilot_hl,
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    enabled = false,
    event = "VeryLazy",
    opts = {
      terminal = {
        split_width_percentage = 0.5,
        provider = "snacks",
        snacks_win_opts = {
          keys = {
            claude_hide = {
              "<c-.>",
              function(self)
                self:hide()
              end,
              mode = "t",
              desc = "Toggle Claude",
            },
          },
        },
      },
    },
    keys = {
      {
        "<c-.>",
        "<cmd>ClaudeCode<cr>",
        desc = "Toggle Claude",
      },
      { "<leader>ac", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      {
        "<leader>af",
        function()
          vim.cmd("ClaudeCodeAdd %")
          vim.schedule(claude_focus_terminal)
        end,
        desc = "Add current file",
      },
      {
        "<leader>at",
        function()
          local mode = vim.fn.mode()
          if mode == "v" or mode == "V" or mode == "\22" then
            local start_line = vim.fn.line("v")
            local end_line = vim.fn.line(".")
            if start_line > end_line then
              start_line, end_line = end_line, start_line
            end
            vim.cmd("ClaudeCodeAdd % " .. start_line .. " " .. end_line)
          else
            local line = vim.fn.line(".")
            vim.cmd("ClaudeCodeAdd % " .. line .. " " .. line)
          end
          vim.schedule(claude_focus_terminal)
        end,
        mode = { "n", "v" },
        desc = "Send to Claude",
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<c-.>",
        function()
          require("sidekick.cli").toggle()
        end,
        mode = { "n", "t", "i", "x" },
        desc = "Sidekick Toggle",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{line}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<Tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return -- "<Tab>" -- fallback
          end
        end,
        mode = { "n" },
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<C-Tab>",
        function()
          if not require("sidekick").clear() then
            return -- "<S-Tab>" -- fallback
          end
        end,
        mode = { "n" },
        expr = true,
        desc = "Close Next Edit Suggestion",
      },
    },
    -- enabled = false,
    ---@type sidekick.Config
    opts = {
      cli = {
        watch = false,
        tools = {
          agy = { cmd = { "agy" } },
          claude_yolo = { cmd = { "claude", "--dangerously-skip-permissions" } },
          omp = { cmd = { "omp" } },
        },
        win = {
          -- Toggling hides by closing the window, which loses any manual
          -- resize. Remember the live width so reopening restores it.
          config = function(term)
            vim.api.nvim_create_autocmd("WinResized", {
              group = term.group,
              callback = function()
                if term.win and vim.api.nvim_win_is_valid(term.win) then
                  term.opts.split.width = vim.api.nvim_win_get_width(term.win)
                end
              end,
            })
          end,
          wo = {
            scrollbind = false,
          },
          split = {
            width = 90,
            height = 20,
          },
          keys = {
            prompt = { "<A-p>", "prompt" },
            -- keep Escape inside the terminal; prevents leaving to Normal mode
            esc = { "<Esc>", "<Esc>", mode = "t", desc = "Sidekick CLI Escape" },
            -- dedicated exit to Normal mode from Sidekick terminal
            stopinsert = { "<C-q>", "stopinsert", mode = "t", desc = "Sidekick CLI stopinsert" },
          },
        },
      },
    },
  },
}
