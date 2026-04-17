return {
  {
    "rebelot/kanagawa.nvim",
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
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          ["@keyword.operator"] = { link = "KeyWord" },
          Boolean = { bold = false },
          ["@lsp.typemod.function.readonly"] = { bold = false },
          IlluminatedWordText = { bg = theme.ui.bg_p2 },
          IlluminatedWordRead = { bg = theme.ui.bg_p2 },
          IlluminatedWordWrite = { bg = theme.ui.bg_p2 },
          DiffDelete = { bg = theme.ui.bg },
          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_m2 },
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m2 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
          PmenuKind = { bg = "NONE" },
          PmenuExtra = { bg = "NONE" },
          CmpGhostText = { fg = theme.syn.comment },
          LspInlayHint = { fg = theme.ui.nontext, bg = theme.ui.bg_m1 },
          CursorLine = { bg = theme.ui.bg_p1 },
          HighlightUndo = { fg = theme.ui.fg, bg = colors.palette.waveBlue2 },
          SnacksPicker = { bg = theme.ui.bg_m1 },
          SnacksPickerBorder = { bg = theme.ui.bg_m1, fg = colors.palette.sumiInk6 },
          SnacksPickerTitle = { bg = theme.ui.bg_m1, fg = colors.palette.sumiInk6 },
          SnacksPickerDir = { bg = "none", fg = "#5d5d72" },
          SnacksIndent = { fg = theme.ui.bg_p2 },
          SnacksIndentScope = { fg = colors.palette.waveAqua2 },
          BlinkIndent = { fg = theme.ui.bg_p2 },
          BlinkIndentScope = { fg = colors.palette.waveAqua2 },
          SnacksDashboardHeader = { fg = colors.palette.springGreen },
          ["@lsp.type.escapeSequence"] = { link = "@string.escape" },
          ["@lsp.type.formatSpecifier"] = { link = "@punctuation.special" },
          ["@lsp.type.variable"] = { link = "@variable" },
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

  { "xeind/nightingale.nvim", enabled = true, lazy = false, priority = 1000 },
  { "kepano/flexoki-neovim", name = "flexoki", enabled = true, lazy = false, priority = 1000 },
  { "dgox16/oldworld.nvim", enabled = true, lazy = false, priority = 1000 },
  {
    "ficcdaf/ashen.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    opts = {
      hl = {
        force_override = {
          Pmenu = { "g_2", "g_9" },
          PmenuSel = { "NONE", "g_8" },
          MatchParen = { "orange_golden", "g_8" },
          ["@diff.add"] = { "green_light" },
        },
        merge_override = {
          SnacksIndent = { "g_9" },
          LspInlayHint = { "g_7", "#0a0a0a" },
          ["@punctuation.bracket"] = { "g_5" },
          SnacksPickerMatch = { "green_light" },
          BlinkCmpLabelMatch = { "green_light" },
          DiffChange = { nil, "g_9" },
          DiffDelete = { nil, "g_9" },
          DiffText = { nil, "g_9" },
          DiffAdd = { nil, "g_9" },
        },
        link = {
          ["@constructor"] = "@punctuation.bracket",
          ["@type"] = "Type",
          ["@number.float.rust"] = "@number",
          test = "String",
        },
      },
    },
  },
  { "zitrocode/carvion.nvim", enabled = true, lazy = false, priority = 1000 },

  {
    "folke/tokyonight.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
    },
  },
  {
    "catppuccin/nvim",
    enabled = false,
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
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
        U = require("catppuccin.utils.colors")
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
  { "rose-pine/neovim", name = "rose-pine", enabled = false },
  {
    "sainnhe/gruvbox-material",
    enabled = false,
    init = function()
      vim.g.gruvbox_material_background = "hard"
    end,
  },
  {
    "slugbyte/lackluster.nvim",
    enabled = false,
    lazy = false,
  },
  {
    "ramojus/mellifluous.nvim",
    enabled = false,
    lazy = false,
  },
  {
    "wtfox/jellybeans.nvim",
    enabled = true,
    config = function()
      require("jellybeans").setup({
        italics = false,
        flat_ui = false,
        plugins = {},
        on_highlights = function(hl, c)
          hl.DiagnosticUnderlineError = { sp = c.diag.error, undercurl = true }
          hl.DiagnosticUnderlineWarn = { sp = c.diag.warning, undercurl = true }
          hl.DiagnosticUnderlineInfo = { sp = c.diag.info, undercurl = true }
          hl.DiagnosticUnderlineHint = { sp = c.diag.hint, undercurl = true }
          hl.Comment.italic = true
          hl.SnacksIndentScope = { fg = "#91a480" }
          hl.SnacksIndent = { fg = "#272727" }
          hl.BlinkCmpMenu = { bg = c.grey_three }
        end,
        on_colors = function(c)
          c.float_bg = "#2f2f2f"
        end,
      })
    end,
  },

  { "mellow-theme/mellow.nvim", enabled = false, lazy = false, priority = 1000 },
  { "kvrohit/rasmus.nvim", enabled = false, lazy = false, priority = 1000 },
  { "Ferouk/bearded-nvim", enabled = false, lazy = false, priority = 1000 },
  { "vague-theme/vague.nvim", enabled = false, lazy = false, priority = 1000 },

  {
    "serhez/teide.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
}
