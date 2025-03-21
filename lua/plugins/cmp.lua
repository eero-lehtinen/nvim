return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    enabled = false,
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-u>",
          clear_suggestion = "<C-¨>", -- actually <C-]>
          accept_word = "<F24>",
        },
        color = {
          suggestion_color = "#739296",
          cterm = 244,
        },
        log_level = "off",
      })

      local api = require("supermaven-nvim.api")
      vim.keymap.set("n", "<leader>ta", function()
        if api.is_running() then
          vim.notify("Supermaven disabled")
        else
          vim.notify("Supermaven enabled")
        end

        api.toggle()
      end, { desc = "[T]oggle [A]I SuperMaven" })

      api.stop()
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    init = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = false,
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4,
          },
        },
        suggestion = {
          auto_trigger = true,
          keymap = {
            -- next = "<C-¨>", -- actually <C-]>
            -- prev = "<C-å>", -- actually <C-[>
            -- dismiss = "<C-ä>", -- below [
            -- accept = "<C-a>",
            -- accept = "<C-u>", -- Next to C-y which is normal complete

            next = "<M-n>",
            prev = "<M-p>",
            accept = "<M-l>",
            dismiss = "<M-e>",
          },
        },
        filetypes = {
          ["*"] = true,
        },
      })

      -- require("copilot.command").disable()
      local enabled = true

      vim.keymap.set("n", "<leader>ta", function()
        require("copilot.command").toggle()
        enabled = not enabled
        if enabled then
          vim.notify("Copilot enabled")
        else
          vim.notify("Copilot disabled")
        end
      end, { desc = "[T]oggle [A]I Copilot" })
    end,
  },
  {
    "Exafunction/codeium.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
    enabled = false,
    config = function()
      require("codeium").setup({
        enable_cmp_source = false,
        virtual_text = {
          enabled = true,
          manual = true,
          key_bindings = {
            accept = "<M-l>",
            next = "<M-n>",
            prev = "<M-p>",
            dismiss = "<M-e>",
          },
        },
      })

      vim.keymap.set("n", "<leader>ta", function()
        local virtual_text = require("codeium.config").options.virtual_text
        virtual_text.manual = not virtual_text.manual
        if not virtual_text.manual then
          vim.notify("Codeium enabled")
        else
          vim.notify("Codeium disabled")
        end
      end, { desc = "[T]oggle [A]I Codeium" })
    end,
  },
  {
    "saghen/blink.cmp",
    -- dev = true,
    version = "v0.*",
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
