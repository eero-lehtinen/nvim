return {
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    -- dev = true,
    config = function()
      require('oklch-color-picker').setup {
        patterns = {
          -- hex = {
          --   priority = -1,
          --   '()#%x%x%x+%f[%W]()',
          -- },
          -- css = {
          --   priority = -1,
          --   -- Commas are not allowed in modern css colors so use [^,] to
          --   -- differentiate from `numbers_in_brackets`. `-` is the same as `*`,
          --   -- but matches the shortest possible sequence.
          --   '()rgb%([^,]-%)()',
          --   '()oklch%([^,]-%)()',
          --   '()hsl%([^,]-%)()',
          -- },
          -- numbers_in_brackets = false,
        },
        -- highlight = {
        -- edit_delay = 0,
        -- },
      }
      -- require('oklch-color-picker.highlight').perf_logging = true
      vim.keymap.set('n', '<leader>v', function()
        require('oklch-color-picker').pick_under_cursor()
      end)
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

  -- {
  --   'NvChad/nvim-colorizer.lua',
  --   opts = {
  --     filetypes = { '*' },
  --     user_default_options = {
  --       RGB = true, -- #RGB hex codes
  --       RRGGBB = true, -- #RRGGBB hex codes
  --       names = false, -- "Name" codes like Blue or blue
  --       RRGGBBAA = true, -- #RRGGBBAA hex codes
  --       AARRGGBB = false, -- 0xAARRGGBB hex codes
  --       rgb_fn = true, -- CSS rgb() and rgba() functions
  --       hsl_fn = true, -- CSS hsl() and hsla() functions
  --       css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
  --       css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
  --       -- Available modes for `mode`: foreground, background,  virtualtext
  --       mode = 'background', -- Set the display mode.
  --       -- Available methods are false / true / "normal" / "lsp" / "both"
  --       -- True is same as normal
  --       tailwind = true, -- Enable tailwind colors
  --       -- parsers can contain values used in |user_default_options|
  --       sass = { enable = true, parsers = { 'css' } }, -- Enable sass colors
  --       virtualtext = '■',
  --       -- update color values even if buffer is not focused
  --       -- example use: cmp_menu, cmp_docs
  --       always_update = false,
  --     },
  --     -- all the sub-options of filetypes apply to buftypes
  --     buftypes = {},
  --   },
  --   dev = true,
  --   lazy = false,
  -- },
}
