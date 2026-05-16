return {
  { "mason-org/mason.nvim", lazy = false, opts = {} },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    ---@module "mason-tool-installer"
    ---@type MasonToolInstallerSettings
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "prettierd",
        "taplo",
        "svelte-language-server",
        -- "tsgo", Crashes
        "vtsls",
        "css-lsp",
        "emmet-language-server",
        "pyrefly",
        "ruff",
        "tailwindcss-language-server",
        "html-lsp",
        "gh-actions-language-server",
        "yaml-language-server",
        "tree-sitter-cli",
      },
      auto_update = true,
      start_delay = 3000,
      debounce_hours = 10,
    },
  },
}
