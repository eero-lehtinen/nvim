return {
  "stevearc/conform.nvim",
  config = function()
    local formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" }, --yapf
      rust = {},
      toml = {},
      sql = { "sqlfmt" },
      c = {},
      cpp = {},
      svelte = {},
    }

    local prettierd_filetypes =
      { "javascript", "typescript", "json", "html", "css", "markdown", "yaml", "typescriptreact", "javascriptreact" }
    for _, ft in ipairs(prettierd_filetypes) do
      formatters_by_ft[ft] = { "prettierd" }
    end

    require("conform").setup({
      formatters_by_ft = formatters_by_ft,
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        end

        local fmtrs = formatters_by_ft[vim.bo[bufnr].filetype]
        if not fmtrs then
          return nil
        end

        if #fmtrs == 0 then
          return { timeout_ms = 1000, lsp_format = "prefer" }
        end

        return { timeout_ms = 1000, lsp_format = "never" }
      end,
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
      require("conform").format({ async = true, lsp_fallback = true, range = range })
    end, { range = true })
  end,
}
