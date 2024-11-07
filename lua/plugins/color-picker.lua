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
  --   config = function()
  --     local ccc = require 'ccc'
  --
  --     ccc.setup {
  --       pickers = {
  --         ccc.picker.hex,
  --         ccc.picker.css_rgb,
  --         ccc.picker.css_hsl,
  --         -- ccc.picker.css_hwb,
  --         -- ccc.picker.css_lab,
  --         -- ccc.picker.css_lch,
  --         -- ccc.picker.css_oklab,
  --         ccc.picker.css_oklch,
  --       },
  --       highlighter = {
  --         auto_enable = true,
  --       },
  --     }
  --   end,
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
