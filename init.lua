-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.termguicolors = true

-- from https://notebook.kulchenko.com/algorithms/alphanumeric-natural-sorting-for-humans-in-lua
local function natural_sort(nodes)
  local function padnum(d)
    return ('%09d%s'):format(#d, d)
  end
  table.sort(nodes, function(a, b)
    local a_dir = a.type == 'directory'
    local b_dir = b.type == 'directory'

    if a_dir and not b_dir then
      return true
    elseif not a_dir and b_dir then
      return false
    end

    return tostring(a.name):gsub('%d+', padnum) < tostring(b.name):gsub('%d+', padnum)
  end)
end

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
    path = '~/repos',
  },
})

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

vim.cmd.colorscheme 'kanagawa'
