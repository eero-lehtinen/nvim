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

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>E', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.api.nvim_create_user_command('Messages', ":new | setlocal buftype=nofile bufhidden=delete noswapfile | silent! put = execute('messages')", {
  nargs = 0,
  desc = 'Show messages in a new window',
})

vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = 'Tab close' })

-- My tabout
local function left_is_whitespace_or_empty()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local left_side = string.sub(line, 1, col)
  return left_side:match '^%s*$' ~= nil
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
