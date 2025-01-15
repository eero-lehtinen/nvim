return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    ---@diagnostic disable: missing-fields
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
          hl = "IndentBlanklineChar",
        },
        animate = {
          enabled = false,
        },
        scope = {
          char = "▏",
          hl = "DiagnosticHint",
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
        layouts = {
          big = {
            layout = {
              box = "horizontal",
              width = 0.95,
              min_width = 120,
              height = 0.9,
              {
                box = "vertical",
                border = "rounded",
                title = "{source} {live}",
                title_pos = "center",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
              { win = "preview", border = "rounded", width = 0.5 },
            },
          },
        },
      },

      -- notifier = { enabled = true },
      -- quickfile = { enabled = true },
      -- statuscolumn = { enabled = true },
      -- words = { enabled = true },
    })
    ---@diagnostic enable: missing-fields

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
    vim.keymap.set("n", "<leader>sd", function()
      Snacks.picker.diagnostics({
        severity = {
          min = vim.diagnostic.severity.INFO,
          max = vim.diagnostic.severity.ERROR,
        },
      })
    end, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sD", function()
      Snacks.picker.diagnostics({
        severity = {
          min = vim.diagnostic.severity.ERROR,
          max = vim.diagnostic.severity.ERROR,
        },
      })
    end, { desc = "[S]earch [D]iagnostics" })
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
  keys = {
    {
      "<leader>G",
      function()
        -- Toggle the profiler highlights
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Scratch buffer",
    },
    {
      "<leader>ps",
      function()
        Snacks.profiler.pick()
      end,
      desc = "Profiler search",
    },
  },
}
