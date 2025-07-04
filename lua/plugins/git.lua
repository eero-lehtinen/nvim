return {
  -- TODO: add vgit.nvim

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
    commit = "9cd665f46ab7af2e49d140d328b8e72ea1cf511b",
    config = function()
      require("gitsigns").setup({
        watch_gitdir = { follow_files = false },
        update_debounce = 200,
      })

      local gitsigns = require("gitsigns")

      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, { desc = "Jump to next hunk" })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, { desc = "Jump to previous hunk" })

      vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "[G]it [P]review Hunk" })
      vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "[G]it [R]eset Hunk" })
      vim.keymap.set("n", "<leader>gb", gitsigns.blame, { desc = "[G]it [B]lame" })
      vim.keymap.set("n", "<leader>gl", function()
        gitsigns.blame_line({ full = true })
      end, { desc = "[G]it Blame [L]ine" })
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
}
