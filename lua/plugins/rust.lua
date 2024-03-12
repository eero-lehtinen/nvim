local rust_lsp_target = function()
  local rust_targets = {
    wasm = 'wasm32-unknown-unknown',
    windows = 'x86_64-pc-windows-msvc',
    macos = 'x86_64-apple-darwin',
    linux = 'x86_64-unknown-linux-gnu',
    android = 'aarch64-linux-android',
    ios = 'aarch64-apple-ios',
  }

  local target_key = vim.env.RUST_LSP_TARGET

  local function get_rust_target(_)
    print('Current Rust target: ' .. (target_key or 'auto'))
  end

  vim.api.nvim_create_user_command('RustTarget', get_rust_target, {
    nargs = 0,
    desc = 'Get Rust target [Set with $RUST_LSP_TARGET]',
  })

  if target_key == nil then
    return nil
  end

  local target = rust_targets[target_key]
  if target == nil then
    vim.notify('Invalid $RUST_LSP_TARGET: ' .. target_key, vim.log.levels.ERROR)
  end

  return target
end

local nmap = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { desc = '(RUST) ' .. desc })
end

return {
  {
    'vxpm/ferris.nvim',
    config = function()
      nmap('<leader>Ro', require 'ferris.methods.open_documentation', '[O]pen Documentation')
      nmap('<leader>Rm', require 'ferris.methods.view_memory_layout', 'View [M]emory Layout')
    end,
  },
  {
    'mrcjkb/rustaceanvim',
    -- dir = '~/repos/rustaceanvim',
    version = '^4', -- Recommended
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
          default_settings = {
            ['rust-analyzer'] = {
              completion = {
                callable = {
                  snippets = 'none',
                },
              },
              cargo = {
                allFeatures = true,
                target = rust_lsp_target(),
                -- features = { 'native-activity' },
              },
              rust = {
                analyzerTargetDir = true,
              },
              check = {
                command = 'clippy',
              },
            },
          },
        },
      }

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
  },
}
