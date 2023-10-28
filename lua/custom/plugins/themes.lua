return {
  'sainnhe/gruvbox-material',
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    opts = {
      keywordStyle = { italic = false },
      statementStyle = { bold = false },
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = 'none',
            },
          },
        },
      },
      overrides = function(colors)
        return {
          Boolean = { bold = false },
          IlluminatedWordText = { bg = colors.theme.ui.bg_p2 },
          IlluminatedWordRead = { bg = colors.theme.ui.bg_p2 },
          IlluminatedWordWrite = { bg = colors.theme.ui.bg_p2 },
          IndentBlanklineChar = { fg = colors.theme.ui.bg_p2 },
          IndentBlanklineContextChar = { fg = colors.theme.ui.whitespace },
          IblIndent = { fg = colors.theme.ui.bg_p2 },
          IblScope = { fg = colors.theme.ui.whitespace },
          IndentLine = { fg = colors.theme.ui.bg_p2 },
          HLIndent1 = { fg = colors.theme.ui.bg_p2 },
          DiffDelete = { bg = colors.theme.ui.bg },
        }
      end,
    },
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      style = 'night',
    },
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      flavour = 'mocha',
      color_overrides = {
        -- mocha = {
        --   base = '#232330',
        --   mantle = '#1b1b22',
        --   crust = '#111116',
        -- }
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        fidget = true,
        leap = true,
        mason = true,
        which_key = true,
      },
      custom_highlights = function(c)
        U = require 'catppuccin.utils.colors'
        return {
          LspInlayHint = { fg = c.overlay1, bg = U.darken(c.surface0, 0.35, c.base) },
          HighlightUndo = { bg = U.darken(c.teal, 0.25, c.base) },
          IlluminatedWordText = { bg = U.darken(c.surface1, 0.4, c.base) },
          IlluminatedWordRead = { bg = U.darken(c.surface1, 0.4, c.base) },
          IlluminatedWordWrite = { bg = U.darken(c.surface1, 0.4, c.base) },
        }
      end,
    },
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
  },
}
