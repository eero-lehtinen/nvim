return {
  'nvim-telescope/telescope.nvim',
  -- branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'debugloop/telescope-undo.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    'nvim-telescope/telescope-media-files.nvim',
  },
  config = function()
    local actions = require 'telescope.actions'

    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
        layout_config = {
          width = 0.85,
          height = 0.85,
          prompt_position = 'top',
        },
        sorting_strategy = 'ascending',
      },
      pickers = {
        find_files = {
          find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
        },
        buffers = {
          sort_lastused = true,
          mappings = {
            i = {
              ['<C-d>'] = actions.delete_buffer + actions.move_to_top,
            },
          },
        },
      },
      extensions = {
        undo = {
          -- side_by_side = true,
          layout_strategy = 'vertical',
          layout_config = {
            preview_height = 0.7,
          },
        },
        media_files = {
          find_cmd = 'rg',
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    require('telescope').load_extension 'undo'
    require('telescope').load_extension 'media_files'

    vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>st', require('telescope.builtin').builtin, { desc = '[S]earch [T]elescope' })

    vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
    vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', function()
      require('telescope.builtin').diagnostics {
        severity_limit = vim.diagnostic.severity.INFO,
      }
    end, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sm', require('telescope').extensions.media_files.media_files, { desc = '[S]earch [M]edia' })
    vim.keymap.set('n', '<leader>sc', '<cmd>Cheatsheet<cr>', { desc = '[S]earch [C]heatsheet' })
    vim.keymap.set('n', '<leader>su', require('telescope').extensions.undo.undo, { desc = '[S]earch [U]ndo tree' })
  end,
}
