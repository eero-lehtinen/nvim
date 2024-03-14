return {
  'ibhagwan/fzf-lua',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local fzf_lua = require 'fzf-lua'
    fzf_lua.setup {
      winopts = {
        width = 0.9,
        preview = {
          horizontal = 'right:55%',
          flip_columns = 130,
        },
      },
      lsp = {
        jump_to_single_result = true,
      },
    }

    vim.cmd [[highlight TermCursor gui=underline]]

    vim.keymap.set('n', '<leader>ss', fzf_lua.builtin, { desc = '[S]earch [S]earcher (Telescope builtins)' })

    vim.keymap.set('n', '<leader>/', fzf_lua.blines, { desc = '[/] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>?', fzf_lua.oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', fzf_lua.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>sf', fzf_lua.files, { desc = '[S]earch [F]iles' })

    vim.keymap.set('n', '<leader>sw', fzf_lua.grep_cword, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', fzf_lua.grep_project, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', function()
      fzf_lua.diagnostics_workspace {
        severity_limit = vim.diagnostic.severity.INFO,
      }
    end, { desc = '[S]earch [D]iagnostics' })

    vim.keymap.set('n', '<leader>sh', fzf_lua.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', fzf_lua.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sc', fzf_lua.commands, { desc = '[S]earch [C]ommands' })
    vim.keymap.set('n', '<leader>sr', fzf_lua.resume, { desc = '[S]earch [R]esume' })

    vim.keymap.set('n', '<leader>sn', function()
      fzf_lua.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    vim.keymap.set('n', '<leader>sr', fzf_lua.resume, { desc = '[S]earch [R]esume' })
  end,
}
