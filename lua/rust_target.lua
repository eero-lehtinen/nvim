local rust_targets = {
  wasm = 'wasm32-unknown-unknown',
  win = 'x86_64-pc-windows-msvc',
  mac = 'x86_64-apple-darwin',
  linux = 'x86_64-unknown-linux-gnu',
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

local function set_rust_target(opts)
  local target = opts.args
  if rust_targets[target] == nil then
    print('Invalid target: ' .. (target or 'nil'))
    return
  end
  save_target_variable(target)
  print('Rust target set to ' .. target)
end

vim.api.nvim_create_user_command('RustTargetSet', set_rust_target, {
  nargs = 1,
  desc = 'Set Rust target',
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

vim.api.nvim_create_user_command('RustTargetGet', function()
  print('Rust target: ' .. load_target_variable())
end, {
  nargs = 0,
  desc = 'Get Rust target',
})

local key = load_target_variable()

if key == 'auto' then
  return nil
else
  return rust_targets[key]
end
