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

local toggle_keymap = function(key, name, option_or_toggle)
  local no_bracket_name = name:gsub('%[', ''):gsub('%]', '')
  local f = function()
    local result
    if type(option_or_toggle) == 'string' then
      vim.opt[option_or_toggle] = not vim.opt[option_or_toggle]
      result = vim.opt[option_or_toggle]
    else
      result = option_or_toggle()
    end

    if result then
      vim.notify('Enabled ' .. no_bracket_name, 'info', { title = 'Option' })
    else
      vim.notify('Disabled ' .. no_bracket_name, 'info', { title = 'Option' })
    end
  end
  vim.keymap.set('n', '<leader>t' .. key, f, { desc = '[T]oggle ' .. name })
end

-- toggling
toggle_keymap('w', '[W]rap', 'wrap')
toggle_keymap('l', '[L]ist (Whitespace Characters)', 'list')
toggle_keymap('p', 'Co[P]ilot', function()
  require('copilot.suggestion').toggle_auto_trigger()
  return vim.b.copilot_suggestion_auto_trigger
end)

if vim.fn.has 'nvim-0.10' == 1 then
  toggle_keymap('h', 'Inlay [H]ints', function()
    local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = 0 }
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
    return not enabled
  end)
end

toggle_keymap('t', '[T]reesitter Highlight', function()
  local enabled = vim.b.ts_highlight
  if enabled then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end
  return not enabled
end)

toggle_keymap('k', '[K]loak', function()
  require('cloak').toggle()
  return vim.b.cloak_enabled
end)
