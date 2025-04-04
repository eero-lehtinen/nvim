return {
  {
    "ray-x/lsp_signature.nvim",
    enabled = false,
    init = function()
      vim.keymap.set("n", "<leader>ts", function()
        require("lsp_signature").toggle_float_win()
      end, { desc = "[T]oggle [S]ignature Popup (i_CTRL-k also works)" })
    end,
  },
  { "smjonas/inc-rename.nvim", opts = { save_in_cmdline_history = false } },
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
      progress = {
        lsp = {
          progress_ringbuf_size = 5000,
        },
      },
    },
  },
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
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      -- Delete default keymaps
      local def = {
        "grn",
        "gra",
        "grr",
        "gri",
        "gO",
      }
      for _, key in ipairs(def) do
        pcall(vim.keymap.del, "n", key)
      end
      pcall(vim.keymap.del, "v", "gra")

      -- Make these nop when not in use, otherwise they will do unexpected commands
      local nops = {
        "<leader>r",
        "<leader>c",
        -- 'gd',
        "gr",
        "gi",
        -- 'gD',
        "<leader>ds",
        "<leader>ws",
        "<leader>wf",
      }
      for _, key in ipairs(nops) do
        vim.keymap.set("n", key, function()
          vim.notify("'" .. key .. "' ignored, no LSP attached", vim.log.levels.INFO)
        end, { silent = true, desc = "LSP nop" })
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc)
            if desc then
              desc = "LSP: " .. desc
            end

            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client == nil or client.name == "copilot" then
            return
          end

          nmap("<leader>r", ":IncRename ", "[R]ename")
          vim.keymap.set(
            { "n", "v" },
            "<leader>c",
            vim.lsp.buf.code_action,
            { buffer = event.buf, desc = "LSP: [C]ode Action" }
          )

          local telescope_found, telescope = pcall(require, "telescope.builtin")
          if telescope_found then
            nmap("gd", telescope.lsp_definitions, "[G]oto [D]efinition")
            nmap("gr", telescope.lsp_references, "[G]oto [R]eferences")
            nmap("gi", telescope.lsp_implementations, "[G]oto [I]mplementation")
            nmap("gD", telescope.lsp_type_definitions, "[G]oto Type [D]efinition")
            nmap("<leader>ds", telescope.lsp_document_symbols, "[D]ocument [S]ymbols")
            nmap("<leader>ws", telescope.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
          end
          local fzf_lua_found, fzf_lua = pcall(require, "fzf-lua")
          if fzf_lua_found then
            nmap("gd", fzf_lua.lsp_definitions, "[G]oto [D]efinition")
            nmap("gr", fzf_lua.lsp_references, "[G]oto [R]eferences")
            nmap("gi", fzf_lua.lsp_implementations, "[G]oto [I]mplementation")
            nmap("gD", fzf_lua.lsp_typedefs, "[G]oto Type [D]efinition")
            nmap("<leader>ds", fzf_lua.lsp_document_symbols, "[D]ocument [S]ymbols")
            nmap("<leader>ws", fzf_lua.lsp_workspace_symbols, "[W]orkspace [S]ymbols")
          end
          if Snacks ~= nil then
            nmap("gd", function()
              Snacks.picker.lsp_definitions()
            end, "[G]oto [D]efinition")
            nmap("gr", function()
              Snacks.picker.lsp_references()
            end, "[G]oto [R]eferences")
            nmap("gi", function()
              Snacks.picker.lsp_implementations()
            end, "[G]oto [I]mplementation")
            nmap("gD", function()
              Snacks.picker.lsp_type_definitions()
            end, "[G]oto Type [D]efinition")
            nmap("<leader>ds", function()
              Snacks.picker.lsp_symbols()
            end, "[D]ocument [S]ymbols")
          end

          nmap("K", vim.lsp.buf.hover, "Hover Documentation")

          -- Lesser used LSP functionality

          vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

          nmap("<leader>wf", function()
            local f = vim.lsp.buf.list_workspace_folders()
            vim.notify("Workspace folders: " .. vim.inspect(f), vim.log.levels.INFO)
          end, "[W]orkspace [F]olders")

          -- require("lsp_signature").on_attach({
          --   toggle_key = "<C-k>",
          --   doc_lines = 0,
          --   hint_enable = false,
          --   max_width = 100,
          --   max_height = 4,
          --   handler_opts = {
          --     border = "none",
          --   },
          -- }, event.buf)
        end,
      })

      local servers = {
        lua_ls = {
          -- filetypes { ...},
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        -- rust_analyzer = {},

        pyright = {},

        -- ts_ls = {},
        vtsls = {
          -- complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              -- completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
        -- eslint = {},
        svelte = {},
        tailwindcss = {},
        cssls = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
        html = {},
        emmet_language_server = {},
        -- typos_lsp = {},
        texlab = {
          texlab = {
            build = {
              onSave = true,
              forwardSearchAfter = true,
              -- args = { '-pv' },
            },
            diagnostics = {
              ignoredPatterns = {
                "Overfull \\\\hbox.*",
                "Package glossaries Warning: No language module.*",
                "Package hyperref Warning: Option .*",
              },
            },
          },
          forwardSearch = {
            executable = "okular",
            args = { "--unique", "file:%p#src:%l%f" },
          },
        },

        taplo = {},

        gopls = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            staticcheck = true,
            semanticTokens = true,
          },
        },

        wgsl_analyzer = {},
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities({}, true)
      end

      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = false,
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
          })
        end,
        ["svelte"] = function()
          -- Fixes svelte+ts file watching issues (at least on Linux)
          local c = vim.deepcopy(capabilities)
          c.workspace.didChangeWatchedFiles = false
          require("lspconfig").svelte.setup({
            capabilities = c,
            settings = servers["svelte"],
          })
        end,
        ["rust_analyzer"] = function() end,
        ["ts_ls"] = function() end,
      })

      require("lspconfig").qmlls.setup({
        cmd = { "qmlls6" },
      })

      -- require('lspconfig').glasgow.setup {}

      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua",
          "prettierd",
          "isort",
          "taplo",
        },
      })

      -- require('coq').lsp_ensure_capabilities(capabilities)
    end,
  },
}
