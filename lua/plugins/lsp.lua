return {
  {
    'ray-x/lsp_signature.nvim',
    opts = {
      toggle_key = '<A-k>',
    },
    init = function()
      vim.keymap.set('n', '<leader>ts', function()
        require('lsp_signature').toggle_float_win()
      end, { desc = '[T]oggle [S]ignature Popup (i_ALT-k also works)' })
    end,
  },
  { 'smjonas/inc-rename.nvim', opts = {} },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            lsp = {
              progress_ringbuf_size = 5000,
            },
          },
        },
      },
      'folke/neodev.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc)
            if desc then
              desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client == nil or client.name == 'copilot' then
            return
          end

          nmap('<leader>r', ':IncRename ', '[R]ename')
          vim.keymap.set({ 'n', 'v' }, '<leader>c', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: [C]ode Action' })

          -- nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          -- nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          -- nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          -- nmap('gD', require('telescope.builtin').lsp_type_definitions, '[G]oto Type [D]efinition')
          -- nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          -- nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          nmap('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')
          nmap('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')
          nmap('gi', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')
          nmap('gD', require('fzf-lua').lsp_typedefs, '[G]oto Type [D]efinition')
          nmap('<leader>ds', require('fzf-lua').lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('<leader>ws', require('fzf-lua').lsp_workspace_symbols, '[W]orkspace [S]ymbols')

          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Lesser used LSP functionality

          nmap('<leader>D', require('fzf-lua').lsp_declarations, 'Goto [D]eclaration')
          nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          vim.lsp.inlay_hint.enable(event.buf, true)

          require('lsp_signature').on_attach({
            doc_lines = 0,
            hint_enable = false,
            handler_opts = {
              border = 'none',
            },
          }, event.buf)
        end,
      })

      require('neodev').setup()

      local servers = {
        lua_ls = {
          -- filetypes { ...},
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        rust_analyzer = {},

        pyright = {},

        tsserver = {},
        eslint = {},
        svelte = {},
        tailwindcss = {},
        cssls = {},
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
                'Overfull \\\\hbox.*',
                'Package glossaries Warning: No language module.*',
                'Package hyperref Warning: Option .*',
              },
            },
          },
          forwardSearch = {
            executable = 'okular',
            args = { '--unique', 'file:%p#src:%l%f' },
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

        -- wgsl_analyzer = {},
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local mason_lspconfig = require 'mason-lspconfig'

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
          }
        end,
        ['rust_analyzer'] = function() end,
      }

      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua',
          'prettierd',
          'isort',
          'taplo',
        },
      }
    end,
  },
  {
    'antosha417/nvim-lsp-file-operations',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-tree.lua',
    },
    config = function()
      require('lsp-file-operations').setup()
    end,
  },
}
