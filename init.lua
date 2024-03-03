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
          ['t'] = { name = '+toggle/tab ', _ = 'which_key_ignore' },
          ['d'] = { name = '+debug/docsymbols/diffview', _ = 'which_key_ignore' },
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
        width = 45,
      },
      live_filter = {
        always_show_folders = false,
      },
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.g.nvim_tree_disable_netrw = 1
    end,
  },
  { 'stevearc/dressing.nvim', opts = {} },
  {
    'NvChad/nvim-colorizer.lua',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      user_default_options = {
        RRGGBBAA = true,
        names = false,
      },
    },
  },
  {
    'tummetott/unimpaired.nvim',
    opts = {
      default_keymaps = false,
      keymaps = {
        lprevious = '[l',
        lnext = ']l',
        lfirst = '[L',
        llast = ']L',
        cprevious = '[q',
        cnext = ']q',
        cfirst = '[Q',
        clast = ']Q',
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
    opts = {},
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
  { 'vxpm/ferris.nvim', opts = {} },
  {
    'mrcjkb/rustaceanvim',
    -- dir = '~/repos/rustaceanvim',
    version = '^4', -- Recommended
    ft = { 'rust' },
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          hover_actions = {
            replace_builtin_hover = false,
            -- border = 'none',
            auto_focus = true,
          },
          enable_clippy = false,
          -- reload_workspace_from_cargo_toml = false,
        },
        server = {
          default_settings = {
            ['rust-analyzer'] = {
              completion = {
                callable = {
                  snippets = 'none',
                },
              },
              cargo = {
                allFeatures = true,
                target = require 'rust_target',
                -- features = { 'native-activity' },
              },
              rust = {
                analyzerTargetDir = true,
              },
              check = {
                command = 'clippy',
              },
            },
          },
        },
      }
    end,
  },
  'jesseleite/nvim-macroni',
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

-- my settings and binds
vim.cmd.colorscheme 'kanagawa'
vim.keymap.set('n', '<leader>T', require('nvim-tree.api').tree.toggle, { desc = 'Nvim [T]ree Toggle' })
vim.keymap.set('n', '<C-9>', '<C-^>', { desc = 'Alternate buffer toggle' })

vim.keymap.set('n', 'Q', '@qj', { desc = 'Run macro named "q"' })
vim.keymap.set('x', 'Q', ':norm @q<CR>', { desc = 'Run macro named "q" in selected lines' })
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>update<cr><esc>', { desc = 'Save file' })
vim.api.nvim_create_autocmd({ 'BufLeave' }, {
  pattern = { '*' },
  command = 'silent! update',
  desc = 'Autosave on switching suffers',
})
vim.keymap.set('i', '<C-i>', '<esc>i', { desc = 'Control as esc + i' })
vim.keymap.set({ 'i', 'c' }, '<C-BS>', '<C-w>', { desc = 'Ctrl Backspace' })
vim.keymap.set({ 'n', 'v' }, 'q:', '<Nop>', { silent = true })

vim.keymap.set('n', 'i', function()
  if #vim.fn.getline '.' == 0 then
    return [["_cc]]
  else
    return 'i'
  end
end, { expr = true, desc = 'Properly indent on empty line when insert' })

-- This is actually how visual mode P (not p) already works
-- vim.keymap.set('x', '<C-p>', '"_dP', { desc = 'Paste without changing register' })

vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = '[T]ab [C]lose' })

-- toggling
vim.keymap.set('n', '<leader>tw', '<cmd>set wrap!<cr>', { desc = '[T]oggle [W]rap' })
vim.keymap.set('n', '<leader>tl', '<cmd>set list!<cr>', { desc = '[T]oggle [L]ist (Whitespace Characters)' })
vim.keymap.set('n', '<leader>tp', function()
  require('copilot.suggestion').toggle_auto_trigger()
end, { desc = '[T]oggle Co[P]ilot' })

if vim.fn.has 'nvim-0.10' == 1 then
  vim.keymap.set('n', '<leader>th', function()
    if vim.lsp.inlay_hint.is_enabled(0) then
      vim.lsp.inlay_hint.enable(0, false)
    else
      vim.lsp.inlay_hint.enable(0, true)
    end
  end, { desc = '[T]oggle Inlay [H]ints' })
end

vim.keymap.set('n', '<leader>tt', function()
  if vim.b.ts_highlight then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end
end, { desc = '[T]oggle [T]reesitter Highlight' })

vim.keymap.set('n', '<leader>tk', '<cmd>CloakToggle<cr>', { desc = '[T]oggle [K]loak' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  command = 'checktime',
})

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.scrolloff = 10
vim.o.listchars = 'tab:» ,extends:›,precedes:‹,space:·,trail:~,nbsp:·,eol:↲'
vim.o.cursorline = true
vim.o.cursorlineopt = 'line,number'
vim.o.undolevels = 10000
if vim.fn.has 'nvim-0.10' == 1 then
  vim.o.smoothscroll = true
end
vim.opt.fillchars:append { diff = '╱' }
vim.o.showmode = false
vim.o.splitright = true
vim.o.splitbelow = true
-- vim.o.inccommand = 'split'
vim.o.hlsearch = false
vim.o.number = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank { priority = 1001 }
  end,
})

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
  },
  severity_sort = true,
}

-- Setup justfile syntax
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = 'justfile',
  callback = function()
    vim.bo.syntax = 'sh'
  end,
})

-- Setup wgsl commentstring
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.wgsl',
  callback = function()
    vim.bo.filetype = 'wgsl'
    vim.bo.commentstring = '// %s'
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
