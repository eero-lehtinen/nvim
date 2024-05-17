return {
  'nvim-telescope/telescope.nvim',
  lazy = false,
  rev = '0.1.6',
  -- enabled = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    'MunifTanjim/nui.nvim',
  },
  config = function()
    local actions = require 'telescope.actions'
    local telescope = require 'telescope'

    telescope.setup {
      defaults = {
        path_display = { 'truncate' },
        layout_config = {
          prompt_position = 'top',
          horizontal = {
            size = {
              width = '90%',
              height = '60%',
            },
          },
          vertical = {
            size = {
              width = '90%',
              height = '90%',
            },
          },
        },
        sorting_strategy = 'ascending',
        mappings = {
          i = {
            ['<C-+>'] = actions.which_key,
            ['<C-u>'] = false,
            ['<C-d>'] = false,
            ['<C-h>'] = actions.select_horizontal,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { 'fd', '--type', 'f', '--follow', '--hidden', '--exclude', '.git' },
        },
        buffers = {
          mappings = {
            i = {
              ['<C-x>'] = actions.delete_buffer + actions.move_to_top,
            },
            n = {
              ['<C-x>'] = actions.delete_buffer + actions.move_to_top,
            },
          },
        },
      },
      extensions = {
        fzf = {},
      },
    }

    pcall(telescope.load_extension, 'fzf')

    local builtin = require 'telescope.builtin'

    local function find_all_files()
      builtin.find_files {
        find_command = { 'fd', '--type', 'f', '--follow', '--hidden', '--no-ignore', '--exclude', '.git' },
      }
    end

    vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]earcher (Telescope builtins)' })

    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sa', find_all_files, { desc = '[S]earch [A]ll Files (Including gitignored)' })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', function()
      builtin.diagnostics {
        severity_limit = vim.diagnostic.severity.INFO,
      }
    end, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = '[S]earch [Q]uickfix' })
    vim.keymap.set('n', '<leader>sl', builtin.loclist, { desc = '[S]earch [L]oclist' })

    -- vim.keymap.set('n', '<leader>sn', function()
    --   builtin.find_files { cwd = vim.fn.stdpath 'config' }
    -- end, { desc = '[S]earch [N]eovim files' })
  end,
}
