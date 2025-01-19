return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    enabled = true,
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
    enabled = false,
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = false,
          -- open = 'C-ö', -- Cöpailot
        },
        layout = {
          position = "bottom", -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          next = "<C-¨>", -- actually <C-]>
          prev = "<C-å>", -- actually <C-[>
          dismiss = "<C-ä>", -- below [
          accept = "<C-u>", -- Next to C-y which is normal complete

          -- these work in wezterm, above ones in kitty
          -- next = '<C-]>', -- actually <C-]>
          -- prev = '<C-[>', -- actually <C-[>
          -- dismiss = [[<C-'>]], -- below [, actually ä
          -- accept = '<C-;>', -- accept C[ö]pailot, actually ö
        },
      },
      filetypes = {
        ["*"] = true,
      },
    },
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
            accept = "<C-u>",
            next = "<A-n>",
            prev = "<A-p>",
            dismiss = "<A-e>",
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
    "iguanacucumber/magazine.nvim",
    enabled = false,
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",

      "hrsh7th/cmp-nvim-lsp",

      "onsails/lspkind.nvim",

      -- (have my own now)
      -- 'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
      luasnip.config.setup({})

      local compare = require("cmp.config.compare")
      local types = require("cmp.types")

      local K = types.lsp.CompletionItemKind
      local kind_order = {
        K.EnumMember,
        K.Field,
        K.Property,
        K.Constant,
        K.Method,
        K.Variable,
        K.Snippet,
        K.Enum,
        K.Function,
        K.Struct,
        K.Constructor,
        K.Class,
        K.Interface,
        K.Module,
        K.Unit,
        K.Value,
        K.Keyword,
        K.Color,
        K.Reference,
        K.Event,
        K.Operator,
        K.TypeParameter,
        K.File,
        K.Folder,
        K.Text,
      }
      local kind_order_map = {}
      for i, k in ipairs(kind_order) do
        kind_order_map[k] = i
      end

      local function my_compare_kind(entry1, entry2)
        local kind1 = kind_order_map[entry1:get_kind()] or 100
        local kind2 = kind_order_map[entry2:get_kind()] or 100
        if kind1 ~= kind2 then
          local diff = kind1 - kind2
          if diff < 0 then
            return true
          elseif diff > 0 then
            return false
          end
        end
        return nil
      end

      ---@diagnostic disable: missing-fields
      cmp.setup({
        sorting = {
          comparators = {
            compare.offset,
            compare.exact,
            -- compare.scopes,
            compare.score,
            compare.recently_used,
            compare.locality,
            my_compare_kind,
            -- compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        preselect = cmp.PreselectMode.None,
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            menu = {
              buffer = "[Buf]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              path = "[Path]",
            },
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-Space>"] = cmp.mapping(function(_) -- C-e works by default to close
            if cmp.visible() then
              cmp.abort()
            else
              cmp.complete({})
            end
          end),
          ["<C-y>"] = cmp.mapping.confirm({
            select = true,
            behavior = cmp.ConfirmBehavior.Insert,
          }),
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.locally_jumpable() then
              luasnip.jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        }, {}),
        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          -- <C-z> toggles the completion menu
          ["<C-y>"] = cmp.mapping.confirm({
            select = true,
          }),
        }),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      cmp.event:on("menu_opened", function()
        vim.b.copilot_suggestion_hidden = true
        -- require('copilot.suggestion').dismiss()
      end)

      cmp.event:on("menu_closed", function()
        vim.b.copilot_suggestion_hidden = false
        -- require('copilot.suggestion').next()
        -- require('copilot.suggestion').prev()
      end)
    end,
  },
  {
    "ms-jpq/coq_nvim",
    enabled = false,
    branch = "coq",
    init = function()
      vim.g.coq_settings = {
        auto_start = true,
        display = {
          pum = {
            fast_close = false,
          },
          preview = {
            border = {
              { "", "NormalFloat" },
              { "", "NormalFloat" },
              { "", "NormalFloat" },
              { " ", "NormalFloat" },
              { "", "NormalFloat" },
              { "", "NormalFloat" },
              { "", "NormalFloat" },
              { " ", "NormalFloat" },
            },
            positions = {
              north = 2,
              south = 4,
              west = 3,
              east = 1,
            },
          },
          statusline = {
            helo = false,
          },
        },
        clients = {
          tags = {
            enabled = false,
          },
          tmux = {
            enabled = false,
          },
        },
      }
    end,
  },
  {
    enabled = false,
    "ms-jpq/coq.artifacts",
    branch = "artifacts",
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

        ["<C-p>"] = { "show", "select_prev" },
        ["<C-n>"] = { "show", "select_next" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<C-l>"] = { "snippet_forward" },

        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
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
          update_delay_ms = 10,
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
        enabled = false,
        window = {
          max_height = 4,
          border = "none",
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
