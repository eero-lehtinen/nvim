-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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

  -- Detect tabstop and shiftwidth automatically
  { 'nmac427/guess-indent.nvim', opts = {} },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup {
        icons = {
          rules = false,
        },
        spec = {
          { '<leader>d', group = 'debug / document symbols' },
          { '<leader>h', group = 'hunk (git)' },
          { '<leader>s', group = 'search' },
          { '<leader>t', group = 'toggle ' },
          { '<leader>w', group = 'workspace symbols' },
          { '<leader>l', group = 'language specific' },
          { '<leader>q', group = 'qflist/loclist' },
          { '<leader>g', group = 'git' },
          { '<leader>m', group = 'surround' },
        },
      }
    end,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
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
    'shellRaining/hlchunk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('hlchunk').setup {
        indent = {
          enable = true,
          style = { vim.api.nvim_get_hl(0, { name = 'IndentBlanklineChar' }) },
          chars = { '▎' },
          ahead_lines = 100,
          delay = 10,
        },
        chunk = {
          enable = true,
          use_treesitter = true,
          duration = 0,
          delay = 80,
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
    opts = {
      labeled_modes = '',
    },
  },
  {
    'echasnovski/mini.surround',
    version = '*',
    opts = {
      mappings = {
        add = '<leader>ma', -- Add surrounding in Normal and Visual modes
        delete = '<leader>md', -- Delete surrounding
        find = '<leader>mf', -- Find surrounding (to the right)
        find_left = '<leader>mF', -- Find surrounding (to the left)
        highlight = '<leader>mh', -- Highlight surrounding
        replace = '<leader>mc', -- Change surrounding
        update_n_lines = '<leader>mn', -- Update `n_lines`
      },
      n_lines = 200,
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
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        git_ignored = false,
      },
      view = {
        -- width = 70,
        float = {
          enable = true,
          open_win_config = function()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            return {
              border = 'rounded',
              relative = 'editor',
              width = 100,
              height = screen_h - 3,
              row = 0,
              col = 1,
            }
          end,
        },
      },
      live_filter = {
        always_show_folders = false,
      },
      diagnostics = {
        enable = true,
      },
      update_focused_file = {
        enable = true,
      },
      sort = {
        sorter = natural_sort,
      },
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.g.nvim_tree_disable_netrw = 1

      vim.keymap.set('n', '<leader>T', require('nvim-tree.api').tree.toggle, { desc = 'File [T]ree Toggle' })
    end,
  },
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
  {
    'folke/noice.nvim',
    enabled = false,
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search
        command_palette = false, -- position the cmdline and popupmenu together
        long_message_to_split = false, -- long messages will be sent to a split
        inc_rename = true, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
    },
    init = function()
      vim.keymap.set('n', '<leader>sn', '<cmd>Noice telescope<cr>', { desc = '[S]earch [N]otifications' })
    end,
  },
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
      enable_tailwind = true,
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
  {
    'tzachar/highlight-undo.nvim',
    opts = {},
  },
  {
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure {
        min_count_to_highlight = 2,
      }
    end,
  },
  -- {
  --   'windwp/nvim-autopairs',
  --   opts = {
  --     -- enable_moveright = false -- could be nice but idk
  --   },
  --   -- config = function()
  --   -- local npairs = require 'nvim-autopairs'
  --   -- npairs.setup {}
  --   -- local conds = require 'nvim-autopairs.conds'
  --   -- local rule = require 'nvim-autopairs.rule'
  --   -- -- doesn't actually work when completing, but at least allows moving out of brackets
  --   -- npairs.add_rules {
  --   --   rule('<', '>'):with_pair(conds.none()):with_move(conds.done()):use_key '>',
  --   -- }
  --   -- end,
  -- },
  -- {
  --   'abecodes/tabout.nvim',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'hrsh7th/nvim-cmp' },
  --   opts = {},
  -- },
  -- {
  --   'kawre/neotab.nvim',
  --   opts = {
  --     tabkey = '',
  --     act_as_tab = false,
  --   },
  --   init = function()
  --     local function left_is_whitespace_or_empty()
  --       local line = vim.fn.getline '.'
  --       local col = vim.fn.col '.'
  --       local left_side = string.sub(line, 1, col - 1)
  --       return left_side:match '^%s*$' ~= nil
  --     end
  --
  --     vim.keymap.set('i', '<TAB>', function()
  --       if left_is_whitespace_or_empty() then
  --         vim.fn.feedkeys('\t', 'n')
  --       else
  --         require('neotab').tabout()
  --       end
  --     end, { noremap = true, silent = true })
  --   end,
  -- },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
  {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup {}
      vim.api.nvim_create_user_command('SearchAndReplace', 'GrugFar', {
        nargs = 0,
        desc = 'Poject wide search and replace',
      })
      vim.api.nvim_create_user_command('FindAndReplace', 'GrugFar', {
        nargs = 0,
        desc = 'Poject wide search and replace',
      })
    end,
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
  {
    'ethanholz/nvim-lastplace',
    opts = {},
  },
  'jesseleite/nvim-macroni', -- Adds `:YankMacro [register]`
  {
    'andymass/vim-matchup',
    enabled = false,
    init = function()
      vim.g.matchup_matchparen_enabled = 0 -- Disables annoying highlighting
      -- Makes matchup not bind z and Z, which conflicts with nvim-surround
      vim.keymap.set({ 'o', 'n', 'x' }, '<F24>z%', '<plug>(matchup-z%)', { noremap = true, silent = true })
      vim.keymap.set({ 'o', 'n', 'x' }, '<F24>Z%', '<plug>(matchup-Z%)', { noremap = true, silent = true })
    end,
  },
  {
    'Wansmer/treesj',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      {
        'echasnovski/mini.splitjoin',
        version = false,
        opts = { mappings = { toggle = '' } },
      },
    },
    init = function()
      local function get_pos_lang()
        local c = vim.api.nvim_win_get_cursor(0)
        local range = { c[1] - 1, c[2], c[1] - 1, c[2] }
        local buf = vim.api.nvim_get_current_buf()
        local ok, parser = pcall(vim.treesitter.get_parser, buf, vim.treesitter.language.get_lang(vim.bo[buf].ft))
        if not ok then
          return ''
        end
        local current_tree = parser:language_for_range(range)
        return current_tree:lang()
      end

      vim.keymap.set('n', '<leader>j', function()
        local tsj_langs = require('treesj.langs')['presets']
        local lang = get_pos_lang()
        if lang ~= '' and tsj_langs[lang] then
          require('treesj').toggle()
        else
          require('mini.splitjoin').toggle()
        end
      end, { desc = 'Toggle [J]oin Node' })
    end,
    config = function()
      require('treesj').setup { use_default_keymaps = false }
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
  {
    'laytan/cloak.nvim',
    opts = {},
  },
  'LunarVim/bigfile.nvim',
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
    },
    init = function()
      -- vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>', { desc = '[S]earch [T]odo Comments' })
      vim.keymap.set('n', '<leader>st', function()
        require('todo-comments.fzf').todo()
      end, { desc = '[S]earch [T]odo Comments' })
    end,
  },
  {
    'rachartier/tiny-devicons-auto-colors.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    event = 'VeryLazy',
    config = function()
      if vim.g.colors_name == 'kanagawa' then
        local colors = require('kanagawa.colors').setup()
        require('tiny-devicons-auto-colors').setup {
          colors = colors.palette,
        }
      elseif vim.g.colors_name == 'oldworld' then
        require('tiny-devicons-auto-colors').setup {
          colors = require('oldworld').palette,
        }
      end
    end,
  },

  'mechatroner/rainbow_csv',

  {
    'stevearc/quicker.nvim',
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      highlight = {
        lsp = false,
        load_buffers = false,
      },
    },
    config = function(_, opts)
      require('quicker').setup(opts)
      vim.keymap.set('n', '<leader>qc', function()
        require('quicker').toggle()
      end, {
        desc = 'Toggle quickfix',
      })
      vim.keymap.set('n', '<leader>ql', function()
        require('quicker').toggle { loclist = true }
      end, {
        desc = 'Toggle loclist',
      })
    end,
  },

  {
    'RaafatTurki/hex.nvim',
    opts = {
      is_file_binary_pre_read = function()
        -- only work on normal buffers
        if vim.bo.ft ~= '' then
          return false
        end
        -- check -b flag
        if vim.bo.bin then
          return true
        end
        -- check ext within binary_ext
        local ext = vim.fn.expand '%:e'
        local binary_ext = { 'out', 'bin', 'png', 'jpg', 'jpeg', 'exe', 'dll', 'glb' }
        if vim.tbl_contains(binary_ext, ext) then
          return true
        end
        -- none of the above
        return false
      end,
    },
  },

  {
    'stevearc/profile.nvim',
    init = function()
      local should_profile = os.getenv 'NVIM_PROFILE'
      if should_profile then
        require('profile').instrument_autocmds()
        if should_profile:lower():match '^start' then
          require('profile').start '*'
        else
          require('profile').instrument '*'
        end
      end

      local function toggle_profile()
        local prof = require 'profile'
        if prof.is_recording() then
          prof.stop()
          vim.ui.input({ prompt = 'Save profile to:', completion = 'file', default = 'profile.json' }, function(filename)
            if filename then
              prof.export(filename)
              vim.notify(string.format('Wrote %s', filename))
            end
          end)
        else
          prof.start '*'
        end
      end
      vim.keymap.set('', '<F9>', toggle_profile)
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
  dev = {
    path = '~/repos',
  },
})

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
