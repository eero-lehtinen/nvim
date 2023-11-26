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
        local theme = colors.theme
        return {
          Boolean = { bold = false },
          ['@lsp.typemod.function.readonly'] = { bold = false },
          IlluminatedWordText = { bg = theme.ui.bg_p2 },
          IlluminatedWordRead = { bg = theme.ui.bg_p2 },
          IlluminatedWordWrite = { bg = theme.ui.bg_p2 },
          IndentBlanklineChar = { fg = theme.ui.bg_p2 },
          IndentBlanklineContextChar = { fg = theme.ui.whitespace },
          IblIndent = { fg = theme.ui.bg_p2 },
          IblScope = { fg = theme.ui.whitespace },
          IndentLine = { fg = theme.ui.bg_p2 },
          HLIndent1 = { fg = theme.ui.bg_p2 },
          DiffDelete = { bg = theme.ui.bg },
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
          PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
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
