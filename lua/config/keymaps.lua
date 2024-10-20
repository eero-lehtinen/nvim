vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', 'Q', '@qj', { desc = 'Run macro named "q"' })
vim.keymap.set('x', 'Q', ':norm @q<CR>', { desc = 'Run macro named "q" in selected lines' })

vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>update<cr><esc>', { desc = 'Save file' })

vim.keymap.set('i', '<C-i>', '<esc>i', { desc = 'Control as esc + i' })
vim.keymap.set({ 'n' }, '<c-.>', '<Nop>', { silent = true })
vim.keymap.set({ 'i', 'c' }, '<C-BS>', '<C-w>', { desc = 'Ctrl Backspace' })
-- vim.keymap.set({ 'i', 'c' }, '<C-h>', '<C-w>', { desc = 'Ctrl Backspace' }) -- needed on some terminals, not kitty
vim.keymap.set({ 'n', 'v' }, 'q:', '<Nop>', { silent = true })

vim.keymap.set('n', 'i', function()
  if #vim.fn.getline '.' == 0 then
    return [["_cc]]
  else
    return 'i'
  end
end, { expr = true, desc = 'Properly indent on empty line when insert' })

vim.keymap.set('n', '<C-9>', '<C-^>', { desc = 'Alternate buffer toggle' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>E', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = 'Tab close' })

-- My tabout
local function left_is_whitespace_or_empty()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local left_side = line:sub(1, pos[2])
  return left_side:find '^%s*$' ~= nil
end

local function tabout()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local right_side = line:sub(pos[2] + 1)
  local jump_pos = right_side:find '["\'`%)%]}>|]'
  if jump_pos then
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + jump_pos })
  end
end

vim.keymap.set('i', '<TAB>', function()
  if left_is_whitespace_or_empty() then
    vim.fn.feedkeys('\t', 'n')
  else
    tabout()
  end
end, { noremap = true, silent = true })

-- Auto updating messages
vim.api.nvim_create_user_command('Messages', function()
  local prev_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)

  -- Open the buffer in a new split window
  vim.api.nvim_command 'split'
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  vim.api.nvim_set_current_win(prev_win)

  local timer = vim.loop.new_timer()

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

    local messages = vim.fn.execute 'messages'
    local lines = vim.split(messages, '\n')
    table.remove(lines, 1)
    if #lines == 0 then
      return
    end
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    vim.fn.execute 'messages clear'

    if cursor_at_bottom then
      local new_line_count = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_win_set_cursor(win, { new_line_count, 0 })
    end
  end

  timer:start(0, 100, vim.schedule_wrap(update_buffer))
end, {
  nargs = 0,
  desc = 'Show messages in a new window',
})
