return {
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    -- dev = true,
    config = function()
      require('oklch-color-picker').setup {
        -- log_level = vim.log.levels.DEBUG,
      }
      -- require('oklch-color-picker.highlight').perf_logging = true
      vim.keymap.set('n', '<leader>v', '<cmd>ColorPickOklch<cr>')
    end,
  },
  -- {
  --   'uga-rosa/ccc.nvim',
  --   dev = true,
  --   opts = {
  --     highlighter = {
  --       auto_enable = true,
  --     },
  --   },
  -- },
  -- {
  --   'brenoprata10/nvim-highlight-colors',
  --   dev = true,
  --   opts = {
  --     enable_var_usage = false,
  --     enable_named_colors = false,
  --   },
  -- },
}
