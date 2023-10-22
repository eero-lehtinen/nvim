-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
--
---@diagnostic disable: missing-fields
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  -- Undocumented nice keymaps:
  -- a: toggle stage
  -- J: next hunk
  -- K: previous hunk
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    opts = {},
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[H]unk [P]review' })
        vim.keymap.set('n', '<leader>hr', require('gitsigns').reset_hunk, { buffer = bufnr, desc = '[H]unk [R]eset' })

        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_c = {
          { 'filename', path = 1 },
        },
      },
    },
  },

  {
    -- add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('ibl').setup {
        -- indent = { char = '│' },
        -- viewport_buffer = { min = 200, max = 600 },
        -- indent = { highlight = 'IndentBlanklineChar' },
        scope = {
          enabled = false,
          -- highlight = 'IndentBlanklineContextChar',
        },
      }
    end,
  },

  -- {
  --   'nvimdev/indentmini.nvim',
  --   event = 'BufEnter',
  --   opts = {
  --     char = '▎',
  --   },
  -- },

  {
    'shellRaining/hlchunk.nvim',
    enabled = false,
    event = { 'UIEnter' },
    opts = {
      chunk = {
        enable = false,
      },
      indent = {
        chars = { '▎' },
        style = { '#363646' },
      },
      line_num = {
        enable = false,
      },
      blank = {
        enable = false,
      },
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    -- branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'debugloop/telescope-undo.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      -- Way too much lag to be usable with Rust.
      -- Somewhat lags with other languages like Lua too.
      -- 'HiPhish/rainbow-delimiters.nvim',
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
          max_lines = 5,
          multiline_threshold = 1,
        },
      },
    },
    build = ':TSUpdate',
  },

  -- my plugins
  {
    'ggandor/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      require('leap').add_default_mappings()
    end,
  },
  {
    'ggandor/flit.nvim',
    dependencies = {
      'ggandor/leap.nvim',
      'tpope/vim-repeat',
    },
    opts = {},
  },
  {
    'kylechui/nvim-surround',
    version = '*',
    dependencies = {
      'tpope/vim-repeat',
    },
    opts = {
      keymaps = {
        insert = '<C-g>z',
        insert_line = '<C-g>Z',
        normal = 'yz',
        normal_cur = 'yzz',
        normal_line = 'yZ',
        normal_cur_line = 'yZZ',
        visual = 'z',
        visual_line = 'Z',
        delete = 'dz',
        change = 'cz',
      },
    },
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      hijack_cursor = true,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
      filters = {
        git_ignored = false,
      },
      view = {
        width = 40,
      },
      live_filter = {
        always_show_folders = false,
      },
    },
  },
  { 'stevearc/dressing.nvim', opts = {} },
  {
    'NvChad/nvim-colorizer.lua',
    opts = {
      user_default_options = {
        RRGGBBAA = true,
        names = false,
      },
    },
  },
  {
    'tummetott/unimpaired.nvim',
    opts = {
      default_keymaps = false,
      keymaps = {
        lprevious = '[l',
        lnext = ']l',
        lfirst = '[L',
        llast = ']L',
        cprevious = '[q',
        cnext = ']q',
        cfirst = '[Q',
        clast = ']Q',
      },
    },
  },
  { 'tzachar/highlight-undo.nvim', opts = {} },
  {
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure {
        min_count_to_highlight = 2,
      }
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'abecodes/tabout.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'hrsh7th/nvim-cmp' },
    opts = {},
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = '[[',
          jump_next = ']]',
          accept = '<CR>',
          refresh = 'gr',
          open = '<A-ö>',
        },
        layout = {
          position = 'bottom', -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        auto_trigger = false,
        keymap = {
          next = '<C-¨>', -- actually <C-]>
          prev = '<C-å>', -- actually <C-[>
          dismiss = '<C-ä>', -- below [
          accept = '<C-ö>', -- run C[ö]yPailot
        },
      },
      filetypes = {
        check = { allTargets = true },
        ['*'] = true,
      },
    },
  },
  { 'ray-x/lsp_signature.nvim', event = 'VeryLazy' },
  'onsails/lspkind.nvim',
  { 'smjonas/inc-rename.nvim', opts = {} },
  'sudormrfbin/cheatsheet.nvim',
  { 'IndianBoy42/tree-sitter-just', opts = {} },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    opts = { open_cmd = 'noswapfile vnew' },
    keys = {
      {
        '<leader>sr',
        function()
          require('spectre').open()
        end,
        desc = '[S]earch and [R]eplace in Project (Spectre)',
      },
    },
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  { 'ethanholz/nvim-lastplace', opts = {} },

  -- Ideas:
  -- - Neogit
  -- - diffview
  -- - project.nvim
  -- - trouble.nvim:llä näkisi koko workspacesta virheet
  -- - vim-matchup, highlighttaa kursorin ympärillä

  -- Import my stuffs
  require 'custom.plugins.formatting',
  require 'custom.plugins.themes',

  -- Possibly import not my stuff
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',
}, {})

-- my settings and binds
vim.cmd.colorscheme 'kanagawa'
vim.keymap.set('n', '<leader>t', require('nvim-tree.api').tree.toggle, { desc = 'Neo [T]ree Toggle' })
vim.keymap.set('n', '<C-j>', '<C-^>', { desc = 'Alternate buffer toggle' })
vim.keymap.set('x', '<C-p>', '"_dP', { desc = 'Paste without changing register' })
vim.keymap.set('n', '<leader>G', '<cmd>tab Git<cr>', { desc = '[G]it Fugitive in a tab', silent = true })
vim.keymap.set('n', '0', '-', { desc = 'Stage Toggle Git Fugitive Ergonomic', remap = true })
vim.keymap.set('n', 'Q', '@q', { desc = 'Run marco named "q"' })
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
vim.api.nvim_create_autocmd({ 'BufLeave' }, {
  pattern = { '*' },
  command = 'silent! update',
  desc = 'Autosave on switching suffers',
})

vim.keymap.set({ 'i' }, '<C-BS>', '<C-w>', { desc = 'Ctrl Backspace' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.nvim_tree_disable_netrw = 1
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.scrolloff = 7
vim.o.listchars = 'tab:» ,extends:›,precedes:‹,space:·,trail:~,nbsp:·,eol:↲'
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
vim.o.undolevels = 10000

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.o.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank { priority = 1001 }
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
    layout_config = {
      width = 0.9,
      height = 0.9,
    },
  },
  pickers = {
    find_files = {
      find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
    },
  },
  extensions = {
    undo = {
      side_by_side = true,
      layout_strategy = 'vertical',
      layout_config = {
        preview_height = 0.7,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
require('telescope').load_extension 'undo'

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>st', require('telescope.builtin').builtin, { desc = '[S]earch [T]elescope' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sc', '<cmd>Cheatsheet<cr>', { desc = '[S]earch [C]heatsheet' })
vim.keymap.set('n', '<leader>u', require('telescope').extensions.undo.undo, { desc = '[U]ndo tree' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = true,

  sync_install = false,
  ignore_install = {},
  modules = {},

  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = 'v',
      node_decremental = 'V',
      scope_incremental = '<c-v>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.diagnostic.config {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
  },
  severity_sort = true,
}
-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', ':IncRename ', '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('gD', require('telescope.builtin').lsp_type_definitions, '[G]oto Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('<leader>gd', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.lsp.inlay_hint(bufnr, true)

  require('lsp_signature').on_attach({
    doc_lines = 0,
    hint_enable = false,
    handler_opts = {
      border = 'none',
    },
  }, bufnr)
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  rust_analyzer = {
    ['rust-analyzer'] = {
      checkOnSave = { command = 'clippy', extraArgs = { '--target-dir', 'target/check' } },
      completion = {
        callable = {
          snippets = 'none',
        },
      },
      -- cargo = { target = 'aarch64-linux-android' },
    },
  },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },

  pyright = {},

  tsserver = {},
  eslint = {},
  svelte = {},
  tailwindcss = {},
  cssls = {},
  html = {},
  emmet_language_server = {},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

require('mason-tool-installer').setup {
  ensure_installed = {
    'stylua',
    'prettierd',
    'isort',
  },
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

local compare = require 'cmp.config.compare'
local types = require 'cmp.types'

local K = types.lsp.CompletionItemKind
local kind_order = {
  K.EnumMember,
  K.Field,
  K.Property,
  K.Constant,
  K.Method,
  K.Variable,
  K.Snippet,
  K.Enum,
  K.Function,
  K.Struct,
  K.Constructor,
  K.Class,
  K.Interface,
  K.Module,
  K.Unit,
  K.Value,
  K.Keyword,
  K.Color,
  K.Reference,
  K.Event,
  K.Operator,
  K.TypeParameter,
  K.File,
  K.Folder,
  K.Text,
}
local kind_order_map = {}
for i, k in ipairs(kind_order) do
  kind_order_map[k] = i
end

local function my_compare_kind(entry1, entry2)
  local kind1 = kind_order_map[entry1:get_kind()] or 100
  local kind2 = kind_order_map[entry2:get_kind()] or 100
  if kind1 ~= kind2 then
    local diff = kind1 - kind2
    if diff < 0 then
      return true
    elseif diff > 0 then
      return false
    end
  end
  return nil
end

---@diagnostic disable: missing-fields
cmp.setup {
  sorting = {
    comparators = {
      compare.offset,
      compare.exact,
      -- compare.scopes,
      compare.score,
      compare.recently_used,
      compare.locality,
      my_compare_kind,
      -- compare.sort_text,
      compare.length,
      compare.order,
    },
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format {
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '...',
      menu = {
        buffer = '[Buf]',
        nvim_lsp = '[LSP]',
        luasnip = '[Snip]',
        path = '[Path]',
      },
    },
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.abort()
      else
        cmp.complete {}
      end
    end),
    ['<CR>'] = cmp.mapping.confirm {
      select = true,
    },
    ['<C-CR>'] = function(fallback)
      cmp.abort()
      fallback()
    end,
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),
}

cmp.setup.cmdline(':', {
  completion = {
    autocomplete = false,
  },
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

-- cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
