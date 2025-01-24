---@diagnostic disable: missing-fields
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  -- version = "*",
  config = function()
    require("snacks").setup({
      bigfile = {
        enabled = true,
        setup = function(ctx)
          vim.schedule(function()
            require("illuminate").pause_buf()
            vim.bo[ctx.buf].syntax = ctx.ft
          end)
        end,
      },
      terminal = { style = "terminal" },
      lazygit = {
        configure = false,
        win = {
          style = {
            backdrop = 70,
            wo = {
              winhighlight = "NormalFloat:SnacksPicker",
            },
          },
        },
      },
      indent = {
        enabled = true,
        indent = {
          char = "▏",
        },
        animate = {
          enabled = false,
        },
        scope = {
          char = "▏",
        },
      },
      gitbrowse = {},
      picker = {
        layout = {
          cycle = true,
          --- Use the default layout or vertical if the window is too narrow
          preset = function()
            return vim.o.columns >= 120 and "big" or "vertical"
          end,
        },
        formatters = {
          file = {
            truncate = 60,
          },
        },
      },

      -- notifier = { enabled = true },
      -- quickfile = { enabled = true },
      -- statuscolumn = { enabled = true },
      -- words = { enabled = true },
    })

    local layouts = require("snacks.picker.config.layouts")
    layouts.big = vim.tbl_deep_extend("keep", { layout = { height = 0.9, width = 0.95 } }, layouts.default)
    layouts.big.layout[2].width = 0.45

    Snacks.toggle.profiler():map("<leader>pp")
    Snacks.toggle.profiler_highlights():map("<leader>ph")

    vim.api.nvim_create_user_command("GitBrowse", function(cmd)
      Snacks.gitbrowse({ line_start = cmd.line1, line_end = cmd.line2 })
    end, { range = true })

    vim.keymap.set("n", "<leader>?", function()
      Snacks.picker.recent()
    end, { desc = "[?] Find recently opened files" })
    vim.keymap.set("n", "<leader><space>", function()
      Snacks.picker.buffers()
    end, { desc = "[ ] Find existing buffers" })
    vim.keymap.set("n", "<leader>/", function()
      Snacks.picker.lines()
    end, { desc = "[/] Fuzzily search in current buffer" })
    vim.keymap.set("n", "<leader>ss", function()
      Snacks.picker()
    end, { desc = "[S]earch [S]earcher (Telescope builtins)" })

    vim.keymap.set("n", "<leader>sf", function()
      Snacks.picker.files({ follow = true, hidden = true })
    end, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sa", function()
      Snacks.picker.files({ follow = true, hidden = true, ignored = true })
    end, { desc = "[S]earch [A]ll Files (Including gitignored)" })
    vim.keymap.set("n", "<leader>sh", function()
      Snacks.picker.help()
    end, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>sw", function()
      Snacks.picker.grep_word()
    end, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>sg", function()
      Snacks.picker.grep()
    end, { desc = "[S]earch by [G]rep" })

    local severity_info = {
      min = vim.diagnostic.severity.INFO,
      max = vim.diagnostic.severity.ERROR,
    }
    local severity_error = {
      min = vim.diagnostic.severity.ERROR,
      max = vim.diagnostic.severity.ERROR,
    }
    vim.keymap.set("n", "<leader>sd", function()
      Snacks.picker.diagnostics({
        severity = severity_info,
      })
    end, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sD", function()
      Snacks.picker.diagnostics_buffer({
        severity = severity_info,
      })
    end, { desc = "[S]earch [D]iagnostics (Buffer)" })
    vim.keymap.set("n", "<leader>se", function()
      Snacks.picker.diagnostics({
        severity = severity_error,
      })
    end, { desc = "[S]earch [E]rrors" })
    vim.keymap.set("n", "<leader>sE", function()
      Snacks.picker.diagnostics_buffer({
        severity = severity_error,
      })
    end, { desc = "[S]earch [E]rrors (Buffer)" })

    vim.keymap.set("n", "<leader>sk", function()
      Snacks.picker.keymaps()
    end, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>sc", function()
      Snacks.picker.commands()
    end, { desc = "[S]earch [C]ommands" })
    vim.keymap.set("n", "<leader>sr", function()
      Snacks.picker.resume()
    end, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>sq", function()
      Snacks.picker.qflist()
    end, { desc = "[S]earch [Q]uickfix" })
    vim.keymap.set("n", "<leader>sl", function()
      Snacks.picker.loclist()
    end, { desc = "[S]earch [L]oclist" })
    vim.keymap.set("n", "<leader>sz", function()
      Snacks.picker.zoxide()
    end, { desc = "[S]earch [Z]oxide" })

    vim.keymap.set("n", "<leader>G", function()
      -- Toggle the profiler highlights
      Snacks.lazygit()
    end, { desc = "Lazygit" })

    vim.keymap.set("n", "<leader>.", function()
      Snacks.scratch()
    end, { desc = "Scratch buffer" })

    vim.keymap.set("n", "<leader>ps", function()
      Snacks.profiler.pick()
    end, { desc = "Profiler search" })

    -- local terms = {}
    --
    -- vim.keymap.set({ "n", "t" }, "<C-g>", function()
    --   if vim.bo.filetype == "fzf" then
    --     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, true, true), "n", false)
    --     return
    --   end
    --
    --   if #terms == 0 then
    --     terms = { Snacks.terminal.open() }
    --     return
    --   end
    --
    --   if terms[1]:valid() then
    --     for _, term in ipairs(terms) do
    --       term:hide()
    --     end
    --   else
    --     for _, term in ipairs(terms) do
    --       term:show()
    --     end
    --   end
    -- end, { desc = "Terminal Toggle" })
    --
    -- vim.api.nvim_create_user_command("TermSplit", function()
    --   table.insert(terms, Snacks.terminal.open())
    -- end, {})
    --
    -- vim.api.nvim_create_user_command("TermClose", function()
    --   local bufnr = vim.api.nvim_get_current_buf()
    --   for i, term in ipairs(terms) do
    --     if term.buf == bufnr then
    --       term:hide()
    --       table.remove(terms, i)
    --     end
    --   end
    -- end, {})
  end,
}
