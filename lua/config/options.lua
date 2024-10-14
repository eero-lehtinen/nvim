vim.cmd.colorscheme 'kanagawa'

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.scrolloff = 10
vim.o.listchars = 'tab:» ,extends:›,precedes:‹,space:·,trail:~,nbsp:·,eol:↲'
vim.o.cursorline = true
vim.o.cursorlineopt = 'line,number'
vim.o.undolevels = 10000
if vim.fn.has 'nvim-0.10' == 1 then
  vim.o.smoothscroll = true
end
vim.opt.fillchars:append { diff = '╱' }
vim.o.showmode = false
vim.o.splitright = true
vim.o.splitbelow = true
-- vim.o.inccommand = 'split'
vim.o.hlsearch = false

vim.o.number = true
vim.o.mouse = 'a'
vim.o.mousescroll = 'ver:7,hor:12'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.virtualedit = 'block'

local get_global = function(key, default)
  if vim.g[key] == nil then
    return default
  end
  return vim.g[key]
end

vim.o.wrap = get_global('wrap', true)
vim.o.list = get_global('list', false)

vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
  },
  severity_sort = true,
}

local toggle_keymap = function(key, name, option_or_toggle)
  local no_bracket_name = name:gsub('%[', ''):gsub('%]', '')
  local f = function()
    local result
    if type(option_or_toggle) == 'string' then
      local wins = vim.api.nvim_list_wins()
      result = not vim.api.nvim_win_get_option(0, option_or_toggle)
      for _, win in ipairs(wins) do
        vim.api.nvim_win_set_option(win, option_or_toggle, result)
      end
      vim.g[option_or_toggle] = result
    else
      result = option_or_toggle()
    end

    if result then
      vim.notify('Enabled ' .. no_bracket_name, 'info', { title = 'Option' })
    else
      vim.notify('Disabled ' .. no_bracket_name, 'info', { title = 'Option' })
    end
  end
  vim.keymap.set('n', '<leader>t' .. key, f, { desc = '[T]oggle ' .. name })
end

-- toggling
toggle_keymap('w', '[W]rap', 'wrap')
toggle_keymap('l', '[L]ist (Whitespace Characters)', 'list')
if vim.fn.has 'nvim-0.10' == 1 then
  toggle_keymap('h', 'Inlay [H]ints', function()
    local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = 0 }
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = nil })
    return not enabled
  end)
end

toggle_keymap('p', 'Co[P]ilot', function()
  require('copilot.suggestion').toggle_auto_trigger()
  return vim.b.copilot_suggestion_auto_trigger
end)

toggle_keymap('t', '[T]reesitter Highlight', function()
  local enabled = vim.b.ts_highlight
  if enabled then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end
  return not enabled
end)

toggle_keymap('k', '[K]loak', function()
  require('cloak').toggle()
  return vim.b.cloak_enabled
end)
