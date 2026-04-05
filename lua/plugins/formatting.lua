return {
  "stevearc/conform.nvim",
  config = function()
    local formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_organize_imports", "ruff_format" },
      sql = { "sqlfmt" },
      gdscript = { "gdscript-formatter" },
      rust = { lsp_format = "prefer" },
      toml = { lsp_format = "prefer" },
      c = { lsp_format = "prefer" },
      cpp = { lsp_format = "prefer" },
      svelte = { lsp_format = "prefer" },
      prisma = { lsp_format = "prefer" },
    }

    local prettierd_filetypes =
      { "javascript", "typescript", "json", "html", "css", "markdown", "yaml", "typescriptreact", "javascriptreact" }
    for _, ft in ipairs(prettierd_filetypes) do
      ---@diagnostic disable-next-line: assign-type-mismatch
      formatters_by_ft[ft] = function(bufnr)
        if require("conform").get_formatter_info("prettierd", bufnr).available then
          return { "prettierd" }
        else
          return { "biome", "biome-organize-imports" }
        end
      end
    end

    require("conform").setup({
      formatters_by_ft = formatters_by_ft,
      default_format_opts = {
        lsp_format = "never",
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        end

        return {}
      end,
      formatters = {
        ["gdscript-formatter"] = {
          command = "gdscript-formatter",
          args = { "$FILENAME" },
          stdin = false,
          cwd = require("conform.util").root_file({ "project.godot", ".git" }),
        },
        prettierd = {
          require_cwd = true,
        },
        -- biome = {
        --   require_cwd = true,
        -- },
        -- ["biome-organize-imports"] = {
        --   require_cwd = true,
        -- },
      },
    })

    vim.keymap.set("n", "<leader>tf", function()
      if vim.b.disable_autoformat == nil or vim.b.disable_autoformat == false then
        vim.b.disable_autoformat = true
        vim.notify("Autoformat disabled for buffer", vim.log.levels.INFO)
      else
        vim.b.disable_autoformat = false
        vim.notify("Autoformat enabled for buffer", vim.log.levels.INFO)
      end
    end, { desc = "[T]oggle [F]ormat on Save" })

    vim.api.nvim_create_user_command("FormatDisable", function()
      vim.g.disable_autoformat = true
    end, {
      desc = "Disable autoformat-on-save",
    })
    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.g.disable_autoformat = false
    end, {
      desc = "Re-enable autoformat-on-save",
    })

    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({ async = true, range = range })
    end, { range = true })
  end,
}
