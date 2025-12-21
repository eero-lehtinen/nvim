return {
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
  "nvim-lua/plenary.nvim",
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      { "mason-org/mason.nvim", config = true },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      {
        "rachartier/tiny-code-action.nvim",
        event = "LspAttach",
        opts = {
          -- backend = "delta",
          picker = {
            "snacks",
            opts = {
              layout = "dropdown",
            },
          },
        },
      },
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

          local tca_found, tca = pcall(require, "tiny-code-action")
          local code_action = vim.lsp.buf.code_action
          if tca_found then
            code_action = tca.code_action
          end
          vim.keymap.set(
            { "n", "x", "v" },
            "<leader>c",
            code_action,
            { buffer = event.buf, desc = "LSP: [C]ode Action" }
          )

          -- local fastaction_found, fastaction = pcall(require, "fastaction")
          -- if fastaction_found then
          --   vim.keymap.set({ "n", "x" }, "<leader>c", function()
          --     local success = pcall(fastaction.code_action)
          --     if not success then
          --       vim.lsp.buf.code_action()
          --     end
          --   end)
          -- end

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

          if client.name == "svelte" then
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                client:notify("$/onDidChangeTsOrJsFile", {
                  uri = ctx.match,
                })
              end,
            })
          end
        end,
      })

      local servers = {
        lua_ls = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },

        -- rust_analyzer = {},

        pyright = {},

        -- ts_ls = {},
        vtsls = {
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

        prismals = {},

        clangd = {},
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities({}, true)
      end

      if vim.env.NO_LSP == nil then
        vim.lsp.enable(vim.tbl_keys(servers))
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("svelte", {
        capabilities = vim.tbl_deep_extend("force", { workspace = { didChangeWwatchedFiles = false } }, capabilities),
      })

      for name, settings in pairs(servers) do
        if next(settings) then
          vim.lsp.config(name, {
            settings = settings,
          })
        end
      end

      -- GDScript LSP setup
      -- Apply settings to editor:
      -- Use External Editor: On
      -- Exec Path: nvim
      -- Exec Flags: --server "\\\\.\\pipe\\godot.pipe" --remote-send "<C-\><C-N>:n {file}<CR>:call cursor({line},{col})<CR>"
      local port = os.getenv("GDScript_Port") or "6005"
      local cmd = { "ncat", "127.0.0.1", port }
      local pipe = [[\\.\pipe\godot.pipe]]
      vim.lsp.config("gdscript", {
        filetype = { "gdscript" },
        name = "Godot",
        cmd = cmd,
        root_dir = vim.fs.dirname(vim.fs.find({ "project.godot", ".git" }, { upward = true })[1]),
        on_attach = function(client, bufnr)
          vim.api.nvim_command("serverstart('" .. pipe .. "')")
        end,
      })
      if vim.env.NO_LSP == nil then
        vim.lsp.enable("gdscript")
      end

      -- require("lspconfig").qmlls.setup({
      --   cmd = { "qmlls6" },
      -- })

      -- require('lspconfig').glasgow.setup {}

      require("mason-tool-installer").setup({
        ensure_installed = {
          "lua-language-server",
          "stylua",
          "prettierd",
          "isort",
          "taplo",
          "svelte-language-server",
          "vtsls",
          "css-lsp",
          "emmet-language-server",
          "prisma-language-server",
          "pyright",
          "tailwindcss-language-server",
          "html-lsp",
        },
      })

      -- require('coq').lsp_ensure_capabilities(capabilities)
    end,
  },
}
