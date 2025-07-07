return {
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    -- dev = true,
    event = "VeryLazy",
    -- version = "*",
    -- enabled = true,
    keys = {
      -- One handed keymap recommended, you will be using the mouse
      { "<leader>v", "<cmd>ColorPickOklch<cr>", desc = "Color pick under cursor" },
    },
    config = function()
      require("oklch-color-picker").setup({
        highlight = {
          bold = true,
          ignore_ft = { "" },
        },
        -- log_level = vim.log.levels.DEBUG,
      })
      -- require("oklch-color-picker.highlight").perf_logging = true
      -- require("oklch-color-picker").highlight.set_lsp_perf_logging(true)
    end,
  },
  -- {
  --   "uga-rosa/ccc.nvim",
  --   dev = true,
  --   enabled = false,
  --   config = function()
  --     local ccc = require("ccc")
  --     ccc.setup({
  --       pickers = {
  --         ccc.picker.hex,
  --         ccc.picker.hex_long,
  --         ccc.picker.hex_short,
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
  --     })
  --   end,
  -- },
  -- {
  --   "brenoprata10/nvim-highlight-colors",
  --   dev = true,
  --   enabled = true,
  --   opts = {
  --     enable_ansi = false,
  --     enable_var_usage = false,
  --     enable_named_colors = false,
  --     enable_tailwind = true,
  --   },
  -- },
  --
  -- {
  --   "catgoose/nvim-colorizer.lua",
  --   dev = true,
  --   enabled = false,
  --   opts = {
  --     filetypes = { "*" },
  --     user_default_options = {
  --       RGB = true, -- #RGB hex codes
  --       RRGGBB = true, -- #RRGGBB hex codes
  --       names = false, -- "Name" codes like Blue or blue
  --       RRGGBBAA = true, -- #RRGGBBAA hex codes
  --       AARRGGBB = true, -- 0xAARRGGBB hex codes
  --       rgb_fn = true, -- CSS rgb() and rgba() functions
  --       hsl_fn = true, -- CSS hsl() and hsla() functions
  --       css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
  --       css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
  --       -- Available modes for `mode`: foreground, background,  virtualtext
  --       mode = "background", -- Set the display mode.
  --       -- Available methods are false / true / "normal" / "lsp" / "both"
  --       -- True is same as normal
  --       tailwind = true, -- Enable tailwind colors
  --       -- parsers can contain values used in |user_default_options|
  --       sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
  --       virtualtext = "■",
  --       -- update color values even if buffer is not focused
  --       -- example use: cmp_menu, cmp_docs
  --       always_update = false,
  --     },
  --     -- all the sub-options of filetypes apply to buftypes
  --     buftypes = {},
  --   },
  --   lazy = false,
  -- },
}
