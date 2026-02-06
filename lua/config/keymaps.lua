vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.keymap.set("n", "Q", "@qj", { desc = 'Run macro named "q"' })
vim.keymap.set("x", "Q", ":norm @q<CR>", { desc = 'Run macro named "q" in selected lines' })

vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>update<cr><esc>", { desc = "Save file" })

-- vim.keymap.set("i", "<C-i>", "<esc>i", { desc = "Control as esc + i" })
vim.keymap.set({ "n" }, "<c-.>", "<Nop>", { silent = true })
vim.keymap.set({ "i", "c" }, "<C-BS>", "<C-w>", { desc = "Ctrl Backspace" })
-- vim.keymap.set({ "i", "c" }, "<C-h>", "<C-w>", { desc = "Ctrl Backspace" }) -- needed on some terminals, not kitty
-- vim.keymap.set({ "n", "v" }, "q:", "<Nop>", { silent = true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

vim.keymap.set("t", "<esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

-- The same thing in terminals
-- vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Go to left window in terminal" }) interferes with ctr-backspace
-- vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Go to bottom window in terminal" })
-- vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Go to top window in terminal" })
-- vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Go to right window in terminal" })

vim.keymap.set("n", "i", function()
  if #vim.fn.getline(".") == 0 then
    return [["_cc]]
  else
    return "i"
  end
end, { expr = true, desc = "Properly indent on empty line when insert" })

vim.keymap.set("n", "<C-9>", "<C-^>", { desc = "Alternate buffer toggle" })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- Remap for dealing with word wrap
vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("n", "gh", "^")
vim.keymap.set("n", "gl", "$")

local severity = {
  min = vim.diagnostic.severity.INFO,
  max = vim.diagnostic.severity.ERROR,
}

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, severity = severity })
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, severity = severity })
end, { desc = "Go to next diagnostic message" })

local diagnostic_config = {
  [true] = {
    virtual_text = false,
    virtual_lines = true,
    severity_sort = true,
  },
  [false] = {
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = "●",
    },
    virtual_lines = false,
    severity_sort = true,
  },
}
vim.g.diagnostic_lines = false
vim.diagnostic.config(diagnostic_config[vim.g.diagnostic_lines])

vim.keymap.set("n", "<leader>E", function()
  vim.g.diagnostic_lines = not vim.g.diagnostic_lines
  vim.diagnostic.config(diagnostic_config[vim.g.diagnostic_lines])
  if vim.g.diagnostic_lines then
    vim.notify("Diagnostic lines enabled", vim.log.levels.INFO)
  else
    vim.notify("Diagnostic lines disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle [E]rror Lines" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Tab close" })

-- My tabout
-- local function left_is_whitespace_or_empty()
--   local pos = vim.api.nvim_win_get_cursor(0)
--   local line = vim.api.nvim_get_current_line()
--   local left_side = line:sub(1, pos[2])
--   return left_side:find("^%s*$") ~= nil
-- end
--
-- local function tabout()
--   local pos = vim.api.nvim_win_get_cursor(0)
--   local line = vim.api.nvim_get_current_line()
--   local right_side = line:sub(pos[2] + 1)
--   local jump_pos = right_side:find("[\"'`%)%]}>|]")
--   if jump_pos then
--     vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + jump_pos })
--   end
-- end

-- vim.keymap.set("i", "<TAB>", function()
--   if left_is_whitespace_or_empty() then
--     vim.fn.feedkeys("\t", "n")
--   else
--     tabout()
--   end
-- end, { noremap = true, silent = true })

-- Auto updating messages
vim.api.nvim_create_user_command("Messages", function()
  local prev_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)

  -- Open the buffer in a new split window
  vim.api.nvim_command("split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  vim.api.nvim_set_current_win(prev_win)

  local timer = vim.uv.new_timer()

  -- Function to update the buffer with recent messages
  local function update_buffer()
    if not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf) then
      timer:stop()
      return
    end
    -- Get the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(win)

    -- Check if the cursor is at the bottom of the buffer
    local line_count = vim.api.nvim_buf_line_count(buf)
    local cursor_at_bottom = cursor_pos[1] == line_count

    local messages = vim.fn.execute("messages")
    local lines = vim.split(messages, "\n")
    table.remove(lines, 1)
    if #lines == 0 then
      return
    end
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    vim.fn.execute("messages clear")

    if cursor_at_bottom then
      local new_line_count = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_win_set_cursor(win, { new_line_count, 0 })
    end
  end

  timer:start(0, 100, vim.schedule_wrap(update_buffer))
end, {
  nargs = 0,
  desc = "Show messages in a new window",
})

local toggle_keymap = function(key, name, option_or_toggle)
  local no_bracket_name = name:gsub("%[", ""):gsub("%]", "")
  local f = function()
    local result
    if type(option_or_toggle) == "string" then
      result = not vim.wo[option_or_toggle]
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.wo[win][option_or_toggle] = result
      end
      vim.g[option_or_toggle] = result
    else
      result = option_or_toggle()
    end

    if result then
      vim.notify("Enabled " .. no_bracket_name, vim.log.levels.INFO, { title = "Option" })
    else
      vim.notify("Disabled " .. no_bracket_name, vim.log.levels.INFO, { title = "Option" })
    end
  end
  vim.keymap.set("n", "<leader>t" .. key, f, { desc = "[T]oggle " .. name })
end

-- toggling
toggle_keymap("w", "[W]rap", "wrap")
toggle_keymap("n", "[N]number", "number")
toggle_keymap("l", "[L]ist (Whitespace Characters)", "list")
toggle_keymap("s", "[S]pell", "spell")
toggle_keymap("h", "Inlay [H]ints", function()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = nil })
  return not enabled
end)

toggle_keymap("p", "Co[P]ilot", function()
  require("copilot.suggestion").toggle_auto_trigger()
  return vim.b.copilot_suggestion_auto_trigger
end)

toggle_keymap("t", "[T]reesitter Highlight", function()
  local enabled = vim.b.ts_highlight
  if enabled then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end
  return not enabled
end)

toggle_keymap("k", "[K]loak", function()
  require("cloak").toggle()
  return vim.b.cloak_enabled
end)

vim.api.nvim_create_user_command("TrimTrailing", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
  vim.notify("Trimmed trailing whitespace", vim.log.levels.INFO, { title = "TrimTrailing" })
end, {
  nargs = 0,
  desc = "Trim trailing whitespace in the current buffer",
})

vim.api.nvim_create_user_command("CopyPath", function(opts)
  local path
  if opts.bang then
    path = vim.fn.expand("%:p")
  else
    path = vim.fn.expand("%:.")
  end
  path = path:gsub("\\", "/")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO, { title = "CopyPath" })
end, {
  bang = true,
  nargs = 0,
  desc = "Copy file path to clipboard (relative to cwd, or absolute with !)",
})
