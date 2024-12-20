return {
  "ibhagwan/fzf-lua",
  lazy = false,
  -- enabled = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local image_formats = { "png", "jpg", "jpeg", "gif", "bmp", "ico", "tif", "tiff", "svg", "webp" }

    local image_preview = {}
    for _, format in ipairs(image_formats) do
      image_preview[format] = { "viu", "-b" }
    end

    local fzf_lua = require("fzf-lua")
    fzf_lua.setup({
      fzf_bin = vim.g.is_windows and "C:\\Users\\eerol\\AppData\\Local\\Microsoft\\WinGet\\Links\\fzf.exe" or "fzf",
      winopts = {
        width = 0.9,
        preview = {
          horizontal = "right:50%",
          flip_columns = 130,
          -- default = 'bat_native', -- could be enabled for performance
        },
      },
      lsp = {
        jump_to_single_result = true,
        -- async_or_timeout = true,
      },
      previewers = {
        builtin = {
          extensions = image_preview,
        },
      },
      grep = {
        rg_glob = true,
      },
      files = {
        git_icons = false,
      },
      keymap = {
        fzf = {
          ["ctrl-q"] = "select-all+accept",
        },
      },
    })

    -- vim.cmd [[highlight TermCursor gui=underline]]

    vim.keymap.set("n", "<leader>?", fzf_lua.oldfiles, { desc = "[?] Find recently opened files" })
    vim.keymap.set("n", "<leader><space>", fzf_lua.buffers, { desc = "[ ] Find existing buffers" })
    vim.keymap.set("n", "<leader>/", fzf_lua.blines, { desc = "[/] Fuzzily search in current buffer" })
    vim.keymap.set("n", "<leader>ss", fzf_lua.builtin, { desc = "[S]earch [S]earcher (fzf-lua builtins)" })

    vim.keymap.set("n", "<leader>sf", fzf_lua.files, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sh", fzf_lua.help_tags, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>sw", fzf_lua.grep_cword, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>sg", fzf_lua.grep_project, { desc = "[S]earch by [G]rep" })
    vim.keymap.set("n", "<leader>sd", function()
      fzf_lua.diagnostics_workspace({
        severity_limit = vim.diagnostic.severity.INFO,
      })
    end, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sD", function()
      fzf_lua.diagnostics_workspace({
        severity_limit = vim.diagnostic.severity.ERROR,
      })
    end, { desc = "[S]earch [D]iagnostics (Errors only)" })

    vim.keymap.set("n", "<leader>sk", fzf_lua.keymaps, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>sc", fzf_lua.commands, { desc = "[S]earch [C]ommands" })
    vim.keymap.set("n", "<leader>sr", fzf_lua.resume, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>sq", fzf_lua.quickfix, { desc = "[S]earch [Q]uickfix" })
    vim.keymap.set("n", "<leader>sl", fzf_lua.loclist, { desc = "[S]earch [L]oclist" })

    vim.keymap.set("n", "<leader>gs", fzf_lua.git_status, { desc = "Search [G]it [S]tatus" })

    -- vim.keymap.set('n', '<leader>sn', function()
    --   fzf_lua.files { cwd = vim.fn.stdpath 'config' }
    -- end, { desc = '[S]earch [N]eovim files' })
  end,
}
