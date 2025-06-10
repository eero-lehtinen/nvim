return {
  -- Git related plugins
  -- Undocumented nice keymaps:
  -- a: toggle stage
  -- J: next hunk
  -- K: previous hunk
  {
    "tpope/vim-fugitive",
    init = function()
      -- vim.keymap.set('n', '<leader>G', '<cmd>tab Git<cr>', { desc = '[G]it Fugitive in a tab', silent = true })
      --
      local function shortcut(s, c)
        vim.api.nvim_create_user_command(s, function()
          print(":" .. c)
          vim.cmd(c)
        end, {})
      end

      shortcut("Gp", "Git push")
      shortcut("Gpf", "Git push --force-with-lease")

      -- vim.api.nvim_create_autocmd('FileType', {
      --   pattern = 'fugitive',
      --   callback = function()
      --     vim.keymap.set('n', '<leader>gp', '<cmd>echo ":Git push" | Git push<cr>', { buffer = true, noremap = true })
      --     vim.keymap.set('n', '<leader>gf', '<cmd>echo ":Git push --force-with-lease" | Git push --force-with-lease<cr>', { buffer = true, noremap = true })
      --   end,
      -- })
    end,
  },

  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    config = function()
      vim.cmd("cnoreabbrev Dv DiffviewOpen")
      vim.cmd("cnoreabbrev Dc DiffviewClose")
      vim.cmd("cnoreabbrev Df DiffviewFileHistory")

      local actions = require("diffview.actions")

      require("diffview").setup({
        hooks = {
          diff_buf_read = function(_) end,
        },
        keymaps = {
          view = {
            { "n", "J", actions.select_next_entry, { desc = "Open the diff for the next file" } },
            { "n", "K", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
          },
          file_panel = {
            { "n", "cc", "<Cmd>Git commit <bar> wincmd J<CR>", { desc = "Commit staged changes" } },
            { "n", "ca", "<Cmd>Git commit --amend <bar> wincmd J<CR>", { desc = "Amend the last commit" } },
            {
              "n",
              "ce",
              "<Cmd>Git commit --amend --no-edit <bar> wincmd J<CR>",
              { desc = "Amend (no edit) the last commit" },
            },
            { "n", "J", actions.select_next_entry, { desc = "Open the diff for the next file" } },
            { "n", "K", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
            { "n", "<C-u>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
            { "n", "<C-d>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
          },
          file_history_panel = {
            { "n", "J", actions.select_next_entry, { desc = "Open the diff for the next file" } },
            { "n", "K", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
          },
        },
      })
    end,
  },
  "nvim-lua/plenary.nvim",

  {
    "lewis6991/gitsigns.nvim",
    enabled = false,
    config = function()
      require("gitsigns").setup({
        watch_gitdir = { follow_files = false },
        update_debounce = 200,
      })

      -- local gitsigns = require("gitsigns")

      -- vim.keymap.set("n", "]c", function()
      --   if vim.wo.diff then
      --     vim.cmd.normal({ "]c", bang = true })
      --   else
      --     gitsigns.nav_hunk("next")
      --   end
      -- end, { desc = "Jump to next hunk" })
      --
      -- vim.keymap.set("n", "[c", function()
      --   if vim.wo.diff then
      --     vim.cmd.normal({ "[c", bang = true })
      --   else
      --     gitsigns.nav_hunk("prev")
      --   end
      -- end, { desc = "Jump to previous hunk" })
      --
      -- vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "[G]it [P]review Hunk" })
      -- vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "[G]it [R]eset Hunk" })
      -- vim.keymap.set("n", "<leader>gb", gitsigns.blame, { desc = "[G]it [B]lame" })
      -- vim.keymap.set("n", "<leader>gl", function()
      --   gitsigns.blame_line({ full = true })
      -- end, { desc = "[G]it Blame [L]ine" })
    end,
  },

  {
    enabled = false,
    "NeogitOrg/neogit",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },

  {
    "tanvirtin/vgit.nvim",
    enabled = true,
    requires = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    -- Lazy loading on 'VimEnter' event is necessary.
    event = "VimEnter",
    config = function()
      require("vgit").setup({
        settings = {
          live_blame = { enabled = false },
          live_gutter = { enabled = true },
        },
      })

      local vgit = require("vgit")

      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          vgit.hunk_down()
        end
      end, { desc = "Jump to next hunk" })
      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          vgit.hunk_up()
        end
      end, { desc = "Jump to previous hunk" })

      vim.keymap.set("n", "<C-j>", vgit.hunk_down, { desc = "Jump to next hunk" })
      vim.keymap.set("n", "<C-k>", vgit.hunk_up, { desc = "Jump to previous hunk" })
      vim.keymap.set("n", "<leader>gs", vgit.buffer_hunk_stage, { desc = "[G]it [S]tage Hunk" })
      vim.keymap.set("n", "<leader>gr", vgit.buffer_hunk_reset, { desc = "[G]it [R]eset Hunk" })
      vim.keymap.set("n", "<leader>gp", vgit.buffer_hunk_preview, { desc = "[G]it [P]review Hunk" })
      vim.keymap.set("n", "<leader>gb", vgit.buffer_blame_preview, { desc = "[G]it [B]lame" })
      vim.keymap.set("n", "<leader>gf", vgit.buffer_diff_preview, { desc = "[G]it [F]ile Diff Preview" })
      vim.keymap.set("n", "<leader>gh", vgit.buffer_history_preview, { desc = "[G]it [H]istory Preview" })
      vim.keymap.set("n", "<leader>gd", vgit.project_diff_preview, { desc = "[G]it [D]iff Preview" })
      vim.keymap.set("n", "<leader>gx", vgit.toggle_diff_preference, { desc = "[G]it [L]ogs Preview" })
    end,
  },
}
