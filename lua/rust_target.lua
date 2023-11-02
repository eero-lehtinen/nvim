local rust_targets = {
  wasm = 'wasm32-unknown-unknown',
  windows = 'x86_64-pc-windows-msvc',
  macos = 'x86_64-apple-darwin',
  linux = 'x86_64-unknown-linux-gnu',
  auto = nil,
}

return rust_targets.windows
