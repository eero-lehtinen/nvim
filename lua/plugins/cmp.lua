return {  
	{
    "folke/lazydev.nvim",
    lazy = false,
    ft = "lua",
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    -- dev = true,
    version = "*",
    lazy = false,
    enabled = true,
    -- build = "cargo build -r",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },

        ["<C-p>"] = { "show", "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "show", "select_next", "fallback_to_mappings" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<C-l>"] = { "snippet_forward" },

        ["<Tab>"] = {},
        ["<S-Tab>"] = {},

        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },

      completion = {
        accept = {
          auto_brackets = {
            -- I don't really like it.
            -- Also it's just unnecessarily laggy, up to 400ms because it uses semantic resolution.
            enabled = false,
          },
        },
        menu = {
          -- draw = {
          --   columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
          -- },
        },
        documentation = {
          auto_show = true, -- disable for now because always shows north and obstructs everything
          auto_show_delay_ms = 300,
          -- update_delay_ms = 10,
          window = {
            max_width = 60,
            direction_priority = {
              menu_north = { "e", "w", "n" },
              menu_south = { "e", "w", "s" },
            },
          },
        },
        list = {
          selection = {
            auto_insert = false,
          },
        },
        -- ghost_text = {
        --   enabled = false,
        -- },
      },

      signature = {
        enabled = true,
        window = {
          max_height = 4,
          border = "none",
          show_documentation = false,
        },
      },
      appearance = {
        -- use_nvim_cmp_as_default = true,
        nerd_font_variant = "normal",
      },
      fuzzy = {
        -- prebuilt_binaries = {
        --   force_version = "v0.9.0",
        -- },
      },
      sources = {
        -- add lazydev to your completion providers
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },
    },
  },
}
