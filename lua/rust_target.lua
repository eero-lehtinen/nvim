local rust_targets = {
  wasm = 'wasm32-unknown-unknown',
  win = 'x86_64-pc-windows-msvc',
  mac = 'x86_64-apple-darwin',
  linux = 'x86_64-unknown-linux-gnu',
  auto = nil,
}

return rust_targets.auto
