vim.o.termguicolors = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.scrolloff = 10
vim.o.listchars = "tab:» ,extends:›,precedes:‹,space:·,trail:~,nbsp:·,eol:↲"
vim.o.cursorline = true
vim.o.cursorlineopt = "line,number"
vim.o.undolevels = 10000
if vim.fn.has("nvim-0.10") == 1 then
  vim.o.smoothscroll = true
end
vim.opt.fillchars:append({ diff = "╱" })
vim.o.showmode = false
vim.o.splitright = true
vim.o.splitbelow = true
-- vim.o.inccommand = 'split'
vim.o.hlsearch = false

vim.o.number = true
vim.o.mouse = "a"
vim.o.mousescroll = "ver:7,hor:12"
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = "yes"
vim.o.updatetime = 250
-- vim.o.timeoutlen = 300
vim.o.completeopt = "menuone,noselect"
vim.o.virtualedit = "block"
vim.o.guicursor = "a:block,n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.o.fileformats = "unix,dos"

if vim.g.is_windows then
  vim.cmd("language en_US")

  local ldata = os.getenv("LOCALAPPDATA")
  vim.o.shell = ldata .. "/Programs/nu/bin/nu.exe"

  vim.o.shellcmdflag = "--login --stdin --no-newline -c"
  vim.o.shellredir = "out+err> %s"
  vim.o.shellpipe =
    "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
  vim.o.shelltemp = false
  vim.o.shellxescape = ""
  vim.o.shellxquote = ""
  vim.o.shellquote = ""
  vim.o.shellslash = true -- converts backslashes to forward slashes, fixes path strings

  -- vim.o.shell = 'pwsh'
  -- vim.o.shellcmdflag =
  --   "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
  --
  -- vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  --
  -- vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'

  -- vim.o.shellquote = ''
  -- vim.o.shellxquote = ''
end

if vim.g.neovide then
  vim.o.guifont = "Iosevka_Custom,Symbols_Nerd_Font:h13.0"
  vim.opt.linespace = 2
  vim.g.neovide_light_radius = 3
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_animation_length = 0.015
  vim.g.neovide_cursor_trail_size = 0.7
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_text_gamma = 0.8
  vim.g.neovide_text_contrast = 0.1

  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-+>", function()
    change_scale_factor(1.25)
  end)
  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1 / 1.25)
  end)

  vim.api.nvim_set_keymap("v", "<sc-c>", '"+y', { noremap = true })
  vim.api.nvim_set_keymap("n", "<sc-v>", 'l"+P', { noremap = true })
  vim.api.nvim_set_keymap("v", "<sc-v>", '"+P', { noremap = true })
  vim.api.nvim_set_keymap("c", "<sc-v>", '<C-o>l<C-o>"+<C-o>P<C-o>l', { noremap = true })
  vim.api.nvim_set_keymap("i", "<sc-v>", '<ESC>l"+Pli', { noremap = true })
  vim.api.nvim_set_keymap("t", "<sc-v>", '<C-\\><C-n>"+Pi', { noremap = true })
end

local get_global = function(key, default)
  if vim.g[key] == nil then
    return default
  end
  return vim.g[key]
end

vim.o.wrap = get_global("wrap", true)
vim.o.list = get_global("list", false)

vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  severity_sort = true,
})
