-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
vim.opt.rtp:prepend(lazypath)

---@diagnostic disable: missing-fields
require('lazy').setup({

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup()

      require('which-key').register {
        ['<leader>'] = {
          ['s'] = { name = '+search', _ = 'which_key_ignore' },
          ['h'] = { name = '+hunk (git)', _ = 'which_key_ignore' },
          ['g'] = { name = '+gitfiles', _ = 'which_key_ignore' },
          ['t'] = { name = '+toggle ', _ = 'which_key_ignore' },
          ['d'] = { name = '+debug/docsymbols', _ = 'which_key_ignore' },
          ['w'] = { name = '+workspace (lsp) ', _ = 'which_key_ignore' },
        },
      }
    end,
  },

  {
    -- add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('ibl').setup {
        -- indent = { char = '│' },
        -- viewport_buffer = { min = 200, max = 600 },
        -- indent = { highlight = 'IndentBlanklineChar' },
        scope = {
          enabled = false,
          -- highlight = 'IndentBlanklineContextChar',
        },
      }
    end,
  },

  {
    'ggandor/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      require('leap').add_default_mappings()
    end,
  },
  {
    'ggandor/flit.nvim',
    dependencies = {
      'ggandor/leap.nvim',
      'tpope/vim-repeat',
    },
    opts = {},
  },
  {
    'kylechui/nvim-surround',
    version = '*',
    dependencies = {
      'tpope/vim-repeat',
    },
    opts = {
      keymaps = {
        insert = '<C-g>z',
        insert_line = '<C-g>Z',
        normal = 'yz',
        normal_cur = 'yzz',
        normal_line = 'yZ',
        normal_cur_line = 'yZZ',
        visual = 'z',
        visual_line = 'Z',
        delete = 'dz',
        change = 'cz',
      },
    },
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      hijack_cursor = true,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
      filters = {
        git_ignored = false,
      },
      view = {
        width = 50,
      },
      live_filter = {
        always_show_folders = false,
      },
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.g.nvim_tree_disable_netrw = 1

      vim.keymap.set('n', '<leader>T', require('nvim-tree.api').tree.toggle, { desc = 'Nvim [T]ree Toggle' })
    end,
  },
  { 'stevearc/dressing.nvim', opts = {} },
  -- {
  --   'NvChad/nvim-colorizer.lua',
  --   event = { 'BufReadPost', 'BufNewFile' },
  --   opts = {
  --     user_default_options = {
  --       RRGGBBAA = true,
  --       names = false,
  --     },
  --   },
  -- },
  {
    'brenoprata10/nvim-highlight-colors',
    opts = {
      enable_named_colors = false,
      enable_tailwind_colors = true,
    },
  },
  {
    'tummetott/unimpaired.nvim',
    lazy = false,
    opts = {
      default_keymaps = false,
      keymaps = {
        lprevious = {
          mapping = '[l',
          description = 'Jump to [count] previous entry in loclist',
          dot_repeat = true,
        },
        lnext = {
          mapping = ']l',
          description = 'Jump to [count] next entry in loclist',
          dot_repeat = true,
        },
        lfirst = {
          mapping = '[L',
          description = 'Jump to first entry in loclist',
          dot_repeat = false,
        },
        llast = {
          mapping = ']L',
          description = 'Jump to last entry in loclist',
          dot_repeat = false,
        },
        cprevious = {
          mapping = '[q',
          description = 'Jump to [count] previous entry in qflist',
          dot_repeat = true,
        },
        cnext = {
          mapping = ']q',
          description = 'Jump to [count] next entry in qflist',
          dot_repeat = true,
        },
        cfirst = {
          mapping = '[Q',
          description = 'Jump to first entry in qflist',
          dot_repeat = false,
        },
        clast = {
          mapping = ']Q',
          description = 'Jump to last entry in qflist',
          dot_repeat = false,
        },
      },
    },
  },
  { 'tzachar/highlight-undo.nvim', opts = {} },
  {
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure {
        min_count_to_highlight = 2,
      }
    end,
  },
  {
    'windwp/nvim-autopairs',
    opts = {
      -- enable_moveright = false -- could be nice but idk
    },
    -- config = function()
    -- local npairs = require 'nvim-autopairs'
    -- npairs.setup {}
    -- local conds = require 'nvim-autopairs.conds'
    -- local rule = require 'nvim-autopairs.rule'
    -- -- doesn't actually work when completing, but at least allows moving out of brackets
    -- npairs.add_rules {
    --   rule('<', '>'):with_pair(conds.none()):with_move(conds.done()):use_key '>',
    -- }
    -- end,
  },
  -- {
  --   'abecodes/tabout.nvim',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'hrsh7th/nvim-cmp' },
  --   opts = {},
  -- },
  {
    'kawre/neotab.nvim',
    opts = {
      tabkey = '',
      act_as_tab = false,
    },
    init = function()
      local function left_is_whitespace_or_empty()
        local line = vim.fn.getline '.'
        local col = vim.fn.col '.'
        local left_side = string.sub(line, 1, col - 1)
        return left_side:match '^%s*$' ~= nil
      end

      vim.keymap.set('i', '<TAB>', function()
        if left_is_whitespace_or_empty() then
          vim.fn.feedkeys('\t', 'n')
        else
          require('neotab').tabout()
        end
      end, { noremap = true, silent = true })
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    opts = { open_cmd = 'noswapfile vnew' },
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
    init = function()
      vim.g.skip_ts_context_commentstring_module = true
    end,
  },
  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  { 'ethanholz/nvim-lastplace', opts = {} },
  'jesseleite/nvim-macroni', -- Adds `:YankMacro [register]`
  {
    'andymass/vim-matchup',
    setup = function() end,
  },
  {
    'Wansmer/treesj',
    keys = { '<leader>j' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup { use_default_keymaps = false }
      vim.keymap.set('n', '<leader>j', require('treesj').toggle, { desc = 'Toggle [J]oin Node' })
    end,
  },
  {
    'mbbill/undotree',
    config = function()
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 48
      vim.g.undotree_DiffpanelHeight = 15
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndotree', silent = true })
    end,
  },
  { 'laytan/cloak.nvim', opts = {} },
  {
    'KabbAmine/vCoolor.vim',
    init = function()
      vim.g.vcoolor_disable_mappings = 1
      vim.g.vcoolor_map = '<A-c>'
    end,
  },
  'LunarVim/bigfile.nvim',
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
    },
    init = function()
      vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>', { desc = '[S]earch [T]odo Comments' })
    end,
  },

  -- 'lewis6991/satellite.nvim',
  -- 'dstein64/nvim-scrollview',

  -- Ideas:
  -- - Neogit
  -- - project.nvim
  -- - actions-preview.nvim

  -- Import my stuff
  { import = 'plugins' },
}, {
  change_detection = {
    notify = false,
  },
})

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

-- vim: ts=2 sts=2 sw=2 et
