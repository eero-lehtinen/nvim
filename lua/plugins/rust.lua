local rust_lsp_target = function()
  local rust_targets = {
    wasm = 'wasm32-unknown-unknown',
    windows = 'x86_64-pc-windows-msvc',
    macos = 'x86_64-apple-darwin',
    linux = 'x86_64-unknown-linux-gnu',
    android = 'aarch64-linux-android',
    ios = 'aarch64-apple-ios',
  }

  local target_key = vim.env.RUST_TARGET

  local function get_rust_target(_)
    print('Current Rust target: ' .. (target_key or 'auto'))
  end

  vim.api.nvim_create_user_command('RustTarget', get_rust_target, {
    nargs = 0,
    desc = 'Get Rust target [Set with $RUST_TARGET]',
  })

  if target_key == nil then
    return nil
  end

  local target = rust_targets[target_key]
  if target == nil then
    vim.notify('Invalid $RUST_TARGET: ' .. target_key, vim.log.levels.ERROR)
  end

  return target
end

local nmap = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { buffer = true, desc = '(RUST) ' .. desc })
end

local features = vim.env.RUST_FEATURES
if features ~= nil then
  features = vim.split(features, ',')
end

return {
  {
    'vxpm/ferris.nvim',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
          nmap('<leader>Ro', require 'ferris.methods.open_documentation', '[O]pen Documentation')
          nmap('<leader>Rm', require 'ferris.methods.view_memory_layout', 'View [M]emory Layout')
        end,
      })
    end,
  },
  {
    'mrcjkb/rustaceanvim',
    -- dir = '~/repos/rustaceanvim',
    version = '*',
    ft = { 'rust' },
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          hover_actions = {
            replace_builtin_hover = false,
            -- border = 'none',
            auto_focus = true,
          },
          enable_clippy = false,
          -- reload_workspace_from_cargo_toml = false,
        },
        server = {
          standalone = false,
          default_settings = {
            ['rust-analyzer'] = {
              completion = {
                callable = {
                  snippets = 'none',
                },
              },
              typing = {
                autoClosingAngleBrackets = {
                  enable = true,
                },
              },
              -- diagnostics = {
              --   experimental = {
              --     enable = true,
              --   },
              -- },
              cargo = {
                target = rust_lsp_target(),
                allFeatures = features == nil,
                features = features,
              },
              rust = {
                analyzerTargetDir = true,
              },
              check = {
                command = 'clippy',
                extraArgs = { '--no-deps' },
              },
            },
          },
        },
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
          nmap('<leader>Rd', function()
            vim.cmd.RustLsp { 'debuggables' }
          end, 'Debug: Rust Debuggables')

          nmap('<leader>Ra', function()
            vim.cmd.RustLsp { 'hover', 'actions' }
          end, 'Hover [A]ctions')

          nmap('<leader>Re', function()
            vim.cmd.RustLsp 'expandMacro'
          end, '[E]xpand Macro')
        end,
      })
    end,
  },
}
