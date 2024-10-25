return {
  {
    'ray-x/lsp_signature.nvim',
    opts = {
      toggle_key = '<C-k>',
    },
    event = 'VeryLazy',
    init = function()
      vim.keymap.set('n', '<leader>ts', function()
        require('lsp_signature').toggle_float_win()
      end, { desc = '[T]oggle [S]ignature Popup (i_CTRL-k also works)' })
    end,
  },
  { 'smjonas/inc-rename.nvim', opts = {} },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
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
      -- Make these nop when not in use, otherwise they will do unexpected commands
      local nops = {
        '<leader>r',
        '<leader>c',
        -- 'gd',
        'gr',
        'gi',
        -- 'gD',
        '<leader>ds',
        '<leader>ws',
        '<leader>wf',
      }
      for _, key in ipairs(nops) do
        vim.keymap.set('n', key, function()
          vim.notify("'" .. key .. "' ignored, no LSP attached", 'info')
        end, { silent = true, desc = 'LSP nop' })
      end

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

          -- local builtin = require 'telescope.builtin'
          -- nmap('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
          -- nmap('gr', builtin.lsp_references, '[G]oto [R]eferences')
          -- nmap('gi', builtin.lsp_implementations, '[G]oto [I]mplementation')
          -- nmap('gD', builtin.lsp_type_definitions, '[G]oto Type [D]efinition')
          -- nmap('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
          -- nmap('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          local fzf_lua = require 'fzf-lua'
          nmap('gd', fzf_lua.lsp_definitions, '[G]oto [D]efinition')
          nmap('gr', fzf_lua.lsp_references, '[G]oto [R]eferences')
          nmap('gi', fzf_lua.lsp_implementations, '[G]oto [I]mplementation')
          nmap('gD', fzf_lua.lsp_typedefs, '[G]oto Type [D]efinition')
          nmap('<leader>ds', fzf_lua.lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('<leader>ws', fzf_lua.lsp_workspace_symbols, '[W]orkspace [S]ymbols')

          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Lesser used LSP functionality

          vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

          nmap('<leader>wf', function()
            local f = vim.lsp.buf.list_workspace_folders()
            vim.notify('Workspace folders: ' .. vim.inspect(f), 'info')
          end, '[W]orkspace [F]olders')

          require('lsp_signature').on_attach({
            doc_lines = 0,
            floating_window = true,
            wrap = false,
            max_width = 120,
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
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        -- rust_analyzer = {},

        pyright = {},

        ts_ls = {},
        -- eslint = {},
        svelte = {},
        tailwindcss = {},
        cssls = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = 'ignore',
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

      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      local capabilities = require('blink.cmp').get_lsp_capabilities({}, true)

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

      -- require('lspconfig').glasgow.setup {}

      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua',
          'prettierd',
          'isort',
          'taplo',
        },
      }

      -- require('coq').lsp_ensure_capabilities(capabilities)
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
