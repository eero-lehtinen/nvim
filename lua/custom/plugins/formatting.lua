return {
  'stevearc/conform.nvim',
  config = function()
    local formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', { 'yapf', 'black' } },
      rust = {}, -- just use the lsp fallback
      toml = { 'taplo' },
    }

    local prettierd_filetypes = { 'javascript', 'typescript', 'svelte', 'json', 'html', 'css', 'markdown', 'yaml' }
    for _, ft in ipairs(prettierd_filetypes) do
      formatters_by_ft[ft] = { 'prettierd' }
    end

    require('conform').setup {
      formatters_by_ft = formatters_by_ft,
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    }

    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = 'Disable autoformat-on-save',
      bang = true,
    })
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Re-enable autoformat-on-save',
    })

    vim.api.nvim_create_user_command('Format', function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ['end'] = { args.line2, end_line:len() },
        }
      end
      require('conform').format { async = true, lsp_fallback = true, range = range }
    end, { range = true })
  end,
}
