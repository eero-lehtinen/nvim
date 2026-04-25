local pending_format = {}
local pending_save = {}
local pre_edit_bases = {} -- keyed by bufnr

local group = vim.api.nvim_create_augroup("AgentPostEdit", { clear = true })
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = group,
  callback = function(ev)
    if pre_edit_bases[ev.buf] ~= nil then
      vim.v.fcs_choice = ""
    end
  end,
})

local function normalize_path(input_path)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local path = vim.fs.normalize(vim.fn.fnamemodify(input_path:gsub("\r", ""), ":p"))
  local in_cwd = vim.startswith(path, cwd)
  if in_cwd then
    path = path:sub(#cwd + 2)
  end
  return path, in_cwd
end

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

-- 3-way merge: buffer (ours) + disk (theirs) with pre-edit snapshot as base.
-- On conflict, keeps the agent's (disk) version.
local function try_merge_buffer(path, bufnr)
  -- Use pre-edit snapshot as base, fall back to git HEAD
  local base = pre_edit_bases[bufnr]
  pre_edit_bases[bufnr] = nil
  if not base then
    local result = vim.system({ "git", "show", "HEAD:" .. path }):wait()
    if result.code ~= 0 then
      return false
    end
    base = result.stdout
  end

  local eol = vim.bo[bufnr].fileformat == "dos" and "\r\n" or vim.bo[bufnr].fileformat == "mac" and "\r" or "\n"

  local ours_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local ours_f, ours_err = write_temp(table.concat(ours_lines, eol) .. eol)
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

  -- Merge: ours (user edits) + base (pre-edit snapshot) + theirs (disk/agent)
  local merge_result = vim.system({ "git", "merge-file", "--theirs", ours_f, base_f, path }):wait()
  if merge_result.code < 0 then
    vim.uv.fs_unlink(ours_f)
    vim.uv.fs_unlink(base_f)
    vim.notify("agent merge: git merge-file failed", vim.log.levels.WARN)
    if view then
      vim.fn.winrestview(view)
    end
    return false
  end

  local merged = vim.fn.readfile(ours_f)

  -- Only update lines that differ
  local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local hunks = vim.text.diff(
    table.concat(current_lines, "\n") .. "\n",
    table.concat(merged, "\n") .. "\n",
    { result_type = "indices", algorithm = "histogram" }
  )
  -- Apply in reverse so earlier line numbers stay valid
  for i = #hunks, 1, -1 do
    ---@diagnostic disable-next-line: need-check-nil
    local sa, ca, sb, cb = hunks[i][1], hunks[i][2], hunks[i][3], hunks[i][4]
    vim.api.nvim_buf_set_lines(bufnr, sa - 1, sa - 1 + ca, false, vim.list_slice(merged, sb, sb + cb - 1))
  end

  -- Update mtime to make checktime believe that we are up to date with the file
  vim.b[bufnr].orig_mtime = vim.uv.fs_stat(path).mtime.sec

  if view then
    vim.fn.winrestview(view)
  end
  vim.uv.fs_unlink(ours_f)
  vim.uv.fs_unlink(base_f)
  return true
end

-- Called before an AI agent edits a file. Saves the pre-edit state as merge base.
function _G.agent_pre_edit(input_path)
  local path = normalize_path(input_path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return ""
  end
  local fd = vim.uv.fs_open(path, "r", 438)
  if not fd then
    return ""
  end
  local bufnr = vim.fn.bufadd(path)
  pre_edit_bases[bufnr] = vim.uv.fs_read(fd, stat.size)
  vim.uv.fs_close(fd)
  return ""
end

-- Called by AI coding agents after editing a file. Syncs the buffer and queues formatting.
function _G.agent_post_edit(input_path)
  vim.schedule(function()
    local path, in_cwd = normalize_path(input_path)

    local bufnr = vim.fn.bufadd(path)
    vim.bo[bufnr].buflisted = true
    vim.fn.bufload(bufnr)

    if (not vim.bo[bufnr].modified) or (not try_merge_buffer(path, bufnr)) then
      vim.bo[bufnr].modified = false
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent! edit!")
      end)
    end

    if in_cwd then
      pending_format[path] = bufnr
    else
      pending_save[path] = bufnr
    end
  end)

  return ""
end

local function format_file(path, bufnr)
  local stat = vim.uv.fs_stat(path)
  if not stat then
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
  end)
end

-- Called when an AI agent finishes its turn. Formats all pending files.
function _G.agent_stop()
  vim.schedule(function()
    for path, bufnr in pairs(pending_format) do
      format_file(path, bufnr)
    end
    for _, bufnr in pairs(pending_save) do
      -- Current buf gets saved by us
      if bufnr ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent! write!")
        end)
      end
    end
    pending_format = {}
    pending_save = {}
  end)

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
          claude_yolo = { cmd = { "claude", "--dangerously-skip-permissions" } },
        },
        win = {
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
