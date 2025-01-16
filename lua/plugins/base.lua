-- from https://notebook.kulchenko.com/algorithms/alphanumeric-natural-sorting-for-humans-in-lua
local function natural_sort(nodes)
  local function padnum(d)
    return ("%09d%s"):format(#d, d)
  end
  table.sort(nodes, function(a, b)
    local a_dir = a.type == "directory"
    local b_dir = b.type == "directory"

    if a_dir and not b_dir then
      return true
    elseif not a_dir and b_dir then
      return false
    end

    return tostring(a.name):gsub("%d+", padnum) < tostring(b.name):gsub("%d+", padnum)
  end)
end

return {

  -- Detect tabstop and shiftwidth automatically
  { "nmac427/guess-indent.nvim", opts = {} },

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
    "ggandor/leap.nvim",
    dependencies = {
      "tpope/vim-repeat",
    },
    config = function()
      require("leap").add_default_mappings()
    end,
  },
  {
    "ggandor/flit.nvim",
    dependencies = {
      "ggandor/leap.nvim",
      "tpope/vim-repeat",
    },
    opts = {
      labeled_modes = "",
    },
  },
  {
    "echasnovski/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "<leader>ma", -- Add surrounding in Normal and Visual modes
        delete = "<leader>md", -- Delete surrounding
        find = "", -- Find surrounding (to the right)
        find_left = "", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        replace = "<leader>mc", -- Change surrounding
        update_n_lines = "", -- Update `n_lines`
      },
      n_lines = 200,
    },
  },
  {
    "echasnovski/mini.ai",
    version = "*",
    -- enabled = false,
    opts = {
      custom_textobjects = {
        f = false,
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
    "nvim-tree/nvim-tree.lua",
    -- for some reason on windows (and maybe windows too) calls some git function and completely freezes the whole editor
    enabled = false,
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      hijack_cursor = true,
      git = {
        enable = false,
      },
      actions = {
        open_file = {
          quit_on_open = true,
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        git_ignored = false,
      },
      view = {
        -- width = 70,
        float = {
          enable = true,
          open_win_config = function()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            return {
              border = "rounded",
              relative = "editor",
              width = 100,
              height = screen_h - 3,
              row = 0,
              col = 1,
            }
          end,
        },
      },
      live_filter = {
        always_show_folders = false,
      },
      diagnostics = {
        enable = true,
      },
      update_focused_file = {
        enable = true,
      },
      sort = {
        sorter = natural_sort,
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "<Esc>", api.tree.close, opts("Close"))
      end,
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.g.nvim_tree_disable_netrw = 1

      vim.keymap.set("n", "<leader>T", require("nvim-tree.api").tree.toggle, { desc = "File [T]ree Toggle" })
    end,
  },
  {
    "stevearc/oil.nvim",
    opts = {
      keymaps = {
        ["<C-h>"] = { "actions.parent", mode = "n" },
        ["<C-l>"] = { "actions.select", mode = "n" },
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
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
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
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
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
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
    -- enabled = false,
    init = function()
      vim.g.matchup_surround_enabled = 0
      vim.g.matchup_matchparen_offscreen = {}
    end,
  },
  {
    "Wansmer/treesj",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      {
        "echasnovski/mini.splitjoin",
        version = false,
        opts = { mappings = { toggle = "<leader>J" } },
      },
    },
    init = function()
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

      vim.keymap.set("n", "<leader>j", function()
        local tsj_langs = require("treesj.langs")["presets"]
        local lang = get_pos_lang()
        if lang ~= "" and tsj_langs[lang] then
          require("treesj").toggle()
        else
          require("mini.splitjoin").toggle()
        end
      end, { desc = "Toggle [J]oin Node" })
    end,
    config = function()
      require("treesj").setup({ use_default_keymaps = false })
    end,
  },
  {
    "mbbill/undotree",
    config = function()
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 48
      vim.g.undotree_DiffpanelHeight = 15
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "[U]ndotree", silent = true })
    end,
  },
  {
    "laytan/cloak.nvim",
    opts = {},
  },

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
    "echasnovski/mini.pairs",
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

  { "ActivityWatch/aw-watcher-vim", enabled = false },

  {
    "sphamba/smear-cursor.nvim",
    enabled = false,
    opts = {
      stiffness = 0.8, -- 0.6      [0, 1]
      trailing_stiffness = 0.5, -- 0.3      [0, 1]
      distance_stop_animating = 0.5, -- 0.1      > 0
      hide_target_hack = false, -- true     boolean
      legacy_computing_symbols_support = true,
    },
  },

  { "chaoren/vim-wordmotion", enabled = false },

  {
    "gregorias/coerce.nvim",
    event = "VeryLazy",
    -- keys = { { "<leader>C" } },
    opts = {
      default_mode_keymap_prefixes = {
        normal_mode = "<leader>C",
        visual_mode = "<leader>C",
      },
      default_mode_mask = {
        normal_mode = true,
        motion_mode = false,
        visual_mode = true,
      },
    },
  },
  -- {
  --   "stevearc/dressing.nvim",
  --   opts = {},
  -- },
}
