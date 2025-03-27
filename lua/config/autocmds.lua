vim.api.nvim_create_autocmd({ "BufLeave" }, {
  pattern = { "*" },
  command = "silent! update",
  desc = "Autosave on switching suffers",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ priority = 1001 })
  end,
})

-- Copied from lazyvim, don't know what it does, I guess checks if the file is changed from the outside
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  command = "checktime",
})

-- Setup justfile syntax
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "justfile",
  callback = function()
    vim.bo.syntax = "sh"
    vim.bo.commentstring = "# %s"
  end,
})

-- Setup wgsl commentstring
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.wgsl",
  callback = function()
    vim.bo.filetype = "wgsl"
    vim.bo.commentstring = "// %s"
  end,
})

-- Setup ron commentstring
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.ron",
  callback = function()
    vim.bo.commentstring = "// %s"
  end,
})

-- Set formatoptions
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  callback = function()
    vim.opt.formatoptions:remove("o")
    vim.cmd("set signcolumn=yes")
  end,
})

vim.api.nvim_create_augroup("vimrc_incsearch_highlight", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = "vimrc_incsearch_highlight",
  pattern = { "/", "\\?" },
  command = "set hlsearch",
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = "vimrc_incsearch_highlight",
  pattern = { "/", "\\?" },
  command = "set nohlsearch",
})
