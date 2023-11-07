local rust_targets = {
  wasm = 'wasm32-unknown-unknown',
  win = 'x86_64-pc-windows-msvc',
  mac = 'x86_64-apple-darwin',
  linux = 'x86_64-unknown-linux-gnu',
  android = 'aarch64-linux-android',
  ios = 'aarch64-apple-ios',
  auto = 'auto',
}

local function load_target_variable()
  local path = vim.fn.stdpath 'data' .. '/rust_target'
  local file = io.open(path, 'r')
  if file == nil then
    return 'auto'
  end
  local target = file:read()
  file:close()
  return target
end

local function save_target_variable(target)
  local path = vim.fn.stdpath 'data' .. '/rust_target'
  local file = io.open(path, 'w')
  if file == nil then
    return
  end
  file:write(target)
  file:close()
end

local function get_or_set_rust_target(opts)
  local target = opts.args

  if target == '' then
    print('Current Rust target: ' .. load_target_variable())
    return
  end

  if rust_targets[target] == nil then
    print('Invalid target: ' .. (target or 'nil'))
    return
  end

  save_target_variable(target)
  print('Rust target set to: ' .. target)
end

vim.api.nvim_create_user_command('RustTarget', get_or_set_rust_target, {
  nargs = '?',
  desc = 'Get/Set Rust target',
  complete = function(arg_lead, _, _)
    local matches = {}
    for k, _ in pairs(rust_targets) do
      if string.find(k, arg_lead) then
        table.insert(matches, k)
      end
    end
    return matches
  end,
})

local key = load_target_variable()

if key == 'auto' then
  return nil
else
  return rust_targets[key]
end
