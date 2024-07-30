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

local check_on_save = true
local no_check_on_save_dirs = {
  -- 'matopeli$',
  -- 'matopeli%-main%-thing$',
  -- 'bevy$',
  -- 'bevy%-fork$',
}
local pwd = vim.fn.getcwd()
for _, dir in ipairs(no_check_on_save_dirs) do
  if pwd:match(dir) then
    check_on_save = false
    vim.notify('Check on save disabled for ' .. dir, vim.log.levels.INFO)
  end
end

return {
  {
    'vxpm/ferris.nvim',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
          nmap('<leader>lo', require 'ferris.methods.open_documentation', '[O]pen Documentation')
          nmap('<leader>lm', require 'ferris.methods.view_memory_layout', 'View [M]emory Layout')
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
              diagnostics = {
                experimental = {
                  enable = true,
                },
              },
              cargo = {
                target = rust_lsp_target(),
                features = features,
              },
              rust = {
                analyzerTargetDir = true,
              },
              check = {
                command = 'clippy',
                extraArgs = { '--no-deps' },
              },
              checkOnSave = check_on_save,
            },
          },
        },
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
          nmap('<leader>ld', function()
            vim.cmd.RustLsp { 'debuggables' }
          end, 'Debug: Rust Debuggables')

          nmap('<leader>la', function()
            vim.cmd.RustLsp { 'hover', 'actions' }
          end, 'Hover [A]ctions')

          nmap('<leader>le', function()
            vim.cmd.RustLsp 'expandMacro'
          end, '[E]xpand Macro')

          nmap('<leader>k', function()
            vim.cmd.RustLsp 'flyCheck'
          end, 'flycheck [k]')
        end,
      })
    end,
  },
}
