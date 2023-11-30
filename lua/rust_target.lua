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
