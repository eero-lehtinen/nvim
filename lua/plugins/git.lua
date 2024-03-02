return {
  -- Git related plugins
  -- Undocumented nice keymaps:
  -- a: toggle stage
  -- J: next hunk
  -- K: previous hunk
  {
    'tpope/vim-fugitive',
    init = function()
      vim.keymap.set('n', '<leader>G', '<cmd>tab Git<cr>', { desc = '[G]it Fugitive in a tab', silent = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fugitive',
        callback = function()
          vim.keymap.set('n', '<leader>p', '<cmd>Git push<cr>', { buffer = true, noremap = true })
        end,
      })
    end,
  },

  'tpope/vim-rhubarb',

  {
    'sindrets/diffview.nvim',
    init = function()
      vim.keymap.set('n', '<leader>dv', '<cmd>DiffviewOpen<cr>', { desc = '[D]iff [V]iew', silent = true })
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
}
