local nmap = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { desc = '(RUST) ' .. desc })
end

nmap('<leader>Rd', function()
  vim.cmd.RustLsp { 'debuggables' }
end, 'Debug: Rust Debuggables')

nmap('<leader>Ra', function()
  vim.cmd.RustLsp { 'hover', 'actions' }
end, 'Hover [A]ctions')

nmap('<leader>Re', function()
  vim.cmd.RustLsp 'expandMacro'
end, '[E]xpand Macro')

nmap('<leader>Ro', require 'ferris.methods.open_documentation', '[O]pen Documentation')
nmap('<leader>Rm', require 'ferris.methods.view_memory_layout', 'View [M]emory Layout')
