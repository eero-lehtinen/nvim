return {

  -- Detect tabstop and shiftwidth automatically
  { "nmac427/guess-indent.nvim", lazy = false, opts = {} },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        icons = {
          rules = false,
        },
        spec = {
          { "<leader>d", group = "debug / document symbols" },
          { "<leader>h", group = "hunk (git)" },
          { "<leader>s", group = "search" },
          { "<leader>t", group = "toggle " },
          { "<leader>w", group = "workspace symbols" },
          { "<leader>l", group = "language specific" },
          { "<leader>q", group = "qflist/loclist" },
          { "<leader>g", group = "git" },
          { "<leader>m", group = "surround" },
        },
        delay = 200,
      })
    end,
  },

  {
    url = "https://codeberg.org/andyg/leap.nvim",
    dependencies = {
      "tpope/vim-repeat",
    },
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
      vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
    end,
  },
  {
    "nvim-mini/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "<leader>ma", -- Add surrounding in Normal and Visual modes
        delete = "<leader>md", -- Delete surrounding
        find = "", -- Find surrounding (to the right)
        find_left = "", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        replace = "<leader>mr", -- Change surrounding
        update_n_lines = "", -- Update `n_lines`
      },
      n_lines = 300,
    },
  },
  {
    "nvim-mini/mini.ai",
    version = "*",
    -- enabled = false,
    opts = {
      custom_textobjects = {
        t = false,
        f = false,
        a = false,
      },
      mappings = {
        around_next = "",
        inside_next = "",
        around_last = "",
        inside_last = "",

        goto_left = "",
        goto_right = "",
      },
      n_lines = 200,
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = { "Oil" },
    opts = {
      default_file_explorer = false,
      keymaps = {
        ["<C-h>"] = { "actions.parent", mode = "n" },
        ["<C-l>"] = { "actions.select", mode = "n" },
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "tzachar/highlight-undo.nvim",
    opts = {},
  },
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("illuminate").configure({
        min_count_to_highlight = 2,
        delay = 70,
      })
    end,
  },
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    cmd = { "MarkdownToggle" },
    config = function()
      local peek = require("peek")
      peek.setup({
        app = "browser",
      })
      vim.api.nvim_create_user_command("MarkdownToggle", function()
        if peek.is_open() then
          peek.close()
        else
          peek.open()
        end
      end, {})
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    keys = { { "<leader>S", "<cmd>SearchAndReplace<cr>", desc = "Search and replace (Grug far)" } },
    cmd = { "SearchAndReplace", "FindAndReplace" },
    config = function()
      require("grug-far").setup({})
      vim.api.nvim_create_user_command("SearchAndReplace", "GrugFar", {
        nargs = 0,
        desc = "Search and replace (Grug far)",
      })
      vim.api.nvim_create_user_command("FindAndReplace", "GrugFar", {
        nargs = 0,
        desc = "Search and replace (Grug far)",
      })
    end,
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
  },
  {
    "ethanholz/nvim-lastplace",
    opts = {},
  },
  "jesseleite/nvim-macroni", -- Adds `:YankMacro [register]`
  {
    "andymass/vim-matchup",
    enabled = true,
    init = function()
      vim.g.matchup_surround_enabled = 0
      vim.g.matchup_matchparen_offscreen = {}
    end,
  },
  {
    "Wansmer/treesj",
    dependencies = {
      {
        "nvim-mini/mini.splitjoin",
        version = false,
        opts = { mappings = { toggle = "<leader>J" } },
        keys = { { "<leader>J", desc = "Toggle [J]oin Mini" } },
      },
    },
    keys = {
      {
        "<leader>j",
        function()
          local function get_pos_lang()
            local c = vim.api.nvim_win_get_cursor(0)
            local range = { c[1] - 1, c[2], c[1] - 1, c[2] }
            local buf = vim.api.nvim_get_current_buf()
            local ok, parser = pcall(vim.treesitter.get_parser, buf, vim.treesitter.language.get_lang(vim.bo[buf].ft))
            if not ok or not parser then
              return ""
            end
            local current_tree = parser:language_for_range(range)
            return current_tree:lang()
          end

          local tsj_langs = require("treesj.langs")["presets"]
          local lang = get_pos_lang()
          if lang ~= "" and tsj_langs[lang] then
            require("treesj").toggle()
          else
            require("mini.splitjoin").toggle()
          end
        end,
        desc = "Toggle [J]oin Node",
      },
    },
    opts = {
      use_default_keymaps = false,
    },
  },
  {
    "laytan/cloak.nvim",
    opts = {},
  },

  { "nvim-tree/nvim-web-devicons" },
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    config = function()
      if vim.g.colors_name == "kanagawa" then
        local colors = require("kanagawa.colors").setup()
        require("tiny-devicons-auto-colors").setup({
          colors = colors.palette,
        })
      elseif vim.g.colors_name == "oldworld" then
        require("tiny-devicons-auto-colors").setup({
          colors = require("oldworld").palette,
        })
      end
    end,
  },

  "mechatroner/rainbow_csv",

  {
    "stevearc/quicker.nvim",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      highlight = {
        lsp = false,
        load_buffers = false,
      },
    },
    config = function(_, opts)
      require("quicker").setup(opts)
      vim.keymap.set("n", "<leader>qc", function()
        require("quicker").toggle()
      end, {
        desc = "Toggle quickfix",
      })
      vim.keymap.set("n", "<leader>ql", function()
        require("quicker").toggle({ loclist = true })
      end, {
        desc = "Toggle loclist",
      })
    end,
  },

  {
    "RaafatTurki/hex.nvim",
    cmd = { "HexToggle" },
    opts = {},
  },

  { "windwp/nvim-ts-autotag", event = "VeryLazy", opts = {} },
  {
    "nvim-mini/mini.pairs",
    opts = {
      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]%W" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]%W" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]%W" },

        [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },

        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^%w\\]%W", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%w\\]%W", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^%w`\\]%W", register = { cr = false } },
        ["|"] = { action = "closeopen", pair = "||", neigh_pattern = "%(%W", register = { cr = false } },
      },
    },
  },

  "tpope/vim-endwise",
  "tpope/vim-abolish",

  { "ActivityWatch/aw-watcher-vim", enabled = false },

  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>y",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
    },
    ---@type YaziConfig
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      keymaps = {
        show_help = "<f1>",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },

  {
    "A7Lavinraj/fyler.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Fyler" },
    keys = {
      {
        "<leader>f",
        function()
          require("fyler").toggle({ kind = "split_left_most" })
        end,
        desc = "Toggle [F]yler",
      },
    },
    config = function()
      require("fyler").setup({
        integrations = {
          icon = "nvim_web_devicons",
        },
        views = {
          finder = {
            default_explorer = true,
            delete_to_trash = true,

            icon = {
              directory_collapsed = "",
              directory_empty = "",
              directory_expanded = "",
            },
          },
        },
      })
    end,
  },

  { "kwkarlwang/bufresize.nvim", opts = {} },

  {
    "ntpeters/vim-better-whitespace",
    init = function()
      vim.g.better_whitespace_enabled = 1
      vim.cmd([[highlight ExtraWhitespace guibg=#993c31]])
    end,
  },
}
