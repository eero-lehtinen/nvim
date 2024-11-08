return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    opts = {
      keywordStyle = { italic = false },
      statementStyle = { bold = false },
      commentStyle = { italic = true },
      colors = {
        palette = {
          -- Rotate all dark colors to be one step darker and
          -- come up with new even dareker sumiInk0
          -- sumiInk0 = '#111117',
          -- sumiInk1 = '#14141B',
          -- sumiInk2 = '#17171E',
          -- sumiInk3 = '#1a1a22',
          -- sumiInk4 = '#21212B',
          -- sumiInk5 = '#2A2A37',
        },
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
          ['@keyword.operator'] = { link = 'KeyWord' },
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
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_m2 },
          PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m2 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
          CopilotSuggestion = { fg = '#739296' },
          CodeiumSuggestion = { fg = '#739296' },
          CmpGhostText = { fg = theme.syn.comment },
          LspInlayHint = { fg = theme.ui.nontext, bg = theme.ui.bg_m1 },
          CursorLine = { bg = theme.ui.bg_p1 },
          HighlightUndo = { fg = theme.ui.fg, bg = colors.palette.waveBlue2 },
          MatchWord = { fg = 'NONE' },
          -- MarkviewHeading1 = { bg = theme.ui.bg_m2 },
          -- MarkviewHeading2 = { bg = theme.ui.bg_m2 },
          -- MarkviewHeading3 = { bg = theme.ui.bg_m2 },
          -- MarkviewHeading4 = { bg = theme.ui.bg_m2 },
          -- MarkviewHeading5 = { bg = theme.ui.bg_m2 },
          -- MarkviewHeading6 = { bg = theme.ui.bg_m2 },
          -- MarkviewListItemMinus = { fg = colors.palette.oniViolet },
          -- MarkviewListItemPlus = { fg = colors.palette.oniViolet },
          -- MarkviewListItemStar = { fg = colors.palette.oniViolet },
          -- MarkviewCode = { bg = theme.ui.bg_p1 },
          -- RainbowDelimiter1 = { fg = colors.palette.springViolet2 },
          -- RainbowDelimiter2 = { fg = colors.palette.oniViolet },
          -- RainbowDelimiter3 = { fg = colors.palette.autumnGreen },
          -- RainbowDelimiter4 = { fg = colors.palette.sakuraPink },
        }
      end,
    },
  },
  {
    'folke/tokyonight.nvim',
    enabled = false,
    lazy = false,
    priority = 1000,
    opts = {
      style = 'night',
    },
  },
  {
    'catppuccin/nvim',
    enabled = false,
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
  { 'rose-pine/neovim', name = 'rose-pine', enabled = false },
  {
    'sainnhe/gruvbox-material',
    enabled = false,
    init = function()
      vim.g.gruvbox_material_background = 'hard'
    end,
  },
  {
    'slugbyte/lackluster.nvim',
    enabled = false,
    lazy = false,
  },
  {
    'ramojus/mellifluous.nvim',
    enabled = false,
    lazy = false,
  },
}
