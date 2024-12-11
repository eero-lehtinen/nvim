-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.termguicolors = true

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',

    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

local function is_windows()
  return vim.uv.os_uname().sysname:find 'Windows' ~= nil
end

---@diagnostic disable: missing-fields
require('lazy').setup({
  { import = 'plugins' },
  -- { import = 'plugins.color-picker' },
  -- { import = 'plugins.colorschemes' },
}, {
  change_detection = {
    notify = false,
  },
  dev = {
    path = is_windows() and 'D:/repos' or '~/repos',
  },
})

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

vim.cmd.colorscheme 'kanagawa'
