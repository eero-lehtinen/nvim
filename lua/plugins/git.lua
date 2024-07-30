return {
  -- Git related plugins
  -- Undocumented nice keymaps:
  -- a: toggle stage
  -- J: next hunk
  -- K: previous hunk
  {
    'tpope/vim-fugitive',
    init = function()
      vim.keymap.set('n', '<leader>g', '<cmd>tab Git<cr>', { desc = '[G]it Fugitive in a tab', silent = true })
      vim.api.nvim_create_user_command('Glogo', 'G log --oneline', {})
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fugitive',
        callback = function()
          vim.keymap.set('n', '<leader>p', '<cmd>echo ":Git push" | Git push<cr>', { buffer = true, noremap = true })
          vim.keymap.set('n', '<leader>f', '<cmd>echo ":Git push --force-with-lease" | Git push --force-with-lease<cr>', { buffer = true, noremap = true })
        end,
      })
    end,
  },

  {
    'sindrets/diffview.nvim',
    config = function()
      vim.cmd 'cnoreabbrev D DiffviewOpen'
      vim.cmd 'cnoreabbrev Dc DiffviewClose'
      vim.cmd 'cnoreabbrev Df DiffviewFileHistory'

      local actions = require 'diffview.actions'

      require('diffview').setup {
        keymaps = {
          view = {
            { 'n', 'J', actions.select_next_entry, { desc = 'Open the diff for the next file' } },
            { 'n', 'K', actions.select_prev_entry, { desc = 'Open the diff for the previous file' } },
          },
          file_panel = {
            { 'n', 'cc', '<Cmd>Git commit <bar> wincmd J<CR>', { desc = 'Commit staged changes' } },
            { 'n', 'ca', '<Cmd>Git commit --amend <bar> wincmd J<CR>', { desc = 'Amend the last commit' } },
            { 'n', 'ce', '<Cmd>Git commit --amend --no-edit <bar> wincmd J<CR>', { desc = 'Amend the last commit' } },
            { 'n', 'J', actions.select_next_entry, { desc = 'Open the diff for the next file' } },
            { 'n', 'K', actions.select_prev_entry, { desc = 'Open the diff for the previous file' } },
            { 'n', 'a', actions.toggle_stage_entry, { desc = 'Stage / unstage the selected entry' } },
          },
          file_history_panel = {
            { 'n', 'J', actions.select_next_entry, { desc = 'Open the diff for the next file' } },
            { 'n', 'K', actions.select_prev_entry, { desc = 'Open the diff for the previous file' } },
          },
        },
      }
    end,
  },
  { 'linrongbin16/gitlinker.nvim', opts = {} },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[H]unk [P]review' })
        vim.keymap.set('n', '<leader>hr', require('gitsigns').reset_hunk, { buffer = bufnr, desc = '[H]unk [R]eset' })

        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  {
    enabled = false,
    'NeogitOrg/neogit',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = true,
  },
}
