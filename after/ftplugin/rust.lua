local nmap = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { desc = '(RUST) ' .. desc })
end

nmap('<F6>', function()
  vim.cmd.RustLsp { 'debuggables' }
end, 'Debug: Rust Debuggables')

nmap('<leader>ra', function()
  vim.cmd.RustLsp { 'hover', 'actions' }
end, 'Hover [A]ctions')

nmap('<leader>rem', function()
  vim.cmd.RustLsp 'expandMacro'
end, '[E]xpand [M]acro')

nmap('<leader>rd', require 'ferris.methods.open_documentation', 'Open [D]ocumentation')
nmap('<leader>rm', require 'ferris.methods.view_memory_layout', 'View [M]emory Layout')
