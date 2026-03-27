return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    init = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            -- next = "<C-¨>", -- actually <C-]>
            -- prev = "<C-å>", -- actually <C-[>
            -- dismiss = "<C-ä>", -- below [
            -- accept = "<C-a>",
            -- accept = "<C-u>", -- Next to C-y which is normal complete

            next = "<M-n>",
            prev = "<M-p>",
            accept = "<F24>",
            dismiss = "<M-e>",
          },
        },
        filetypes = {
          ["*"] = true,
        },
        -- copilot_model = "gpt-4o-copilot", -- just use the default model
        server = {
          -- type = "binary",
        },
      })

      -- require("copilot.command").disable()
      local enabled = true

      vim.keymap.set("n", "<leader>ta", function()
        require("copilot.command").toggle()
        enabled = not enabled
        if enabled then
          vim.notify("Copilot enabled")
        else
          vim.notify("Copilot disabled")
        end
      end, { desc = "[T]oggle [A]I Copilot" })

      vim.keymap.set("i", "<C-u>", function()
        if require("copilot.suggestion").has_next() then
          require("copilot.suggestion").accept()
        end
      end, { desc = "Accept Copilot Suggestion" })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    opts = {
      focuse_after_send = true,
      terminal = {
        split_width_percentage = 0.5,
        provider = "snacks",
        snacks_win_opts = {
          keys = {
            claude_hide = {
              "<c-.>",
              function(self)
                self:hide()
              end,
              mode = "t",
              desc = "Toggle Claude",
            },
          },
        },
      },
    },
    keys = {
      {
        "<c-.>",
        "<cmd>ClaudeCode<cr>",
        desc = "Toggle Claude",
      },
      { "<leader>ac", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>af", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current file" },
      {
        "<leader>at",
        function()
          local mode = vim.fn.mode()
          if mode == "v" or mode == "V" or mode == "\22" then
            vim.cmd("ClaudeCodeSend")
          else
            vim.cmd("normal! V")
            vim.cmd("ClaudeCodeSend")
          end
        end,
        mode = { "n", "v" },
        desc = "Send to Claude",
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    keys = {
      -- {
      --   "<leader>at",
      --   function()
      --     require("sidekick.cli").send({ msg = "{this}" })
      --   end,
      --   mode = { "x", "n" },
      --   desc = "Send This",
      -- },
      -- {
      --   "<leader>af",
      --   function()
      --     require("sidekick.cli").send({ msg = "{file}" })
      --   end,
      --   desc = "Send File",
      -- },
      -- {
      --   "<leader>av",
      --   function()
      --     require("sidekick.cli").send({ msg = "{selection}" })
      --   end,
      --   mode = { "x" },
      --   desc = "Send Visual Selection",
      -- },
      -- {
      --   "<leader>ap",
      --   function()
      --     require("sidekick.cli").prompt()
      --   end,
      --   mode = { "n", "x" },
      --   desc = "Sidekick Select Prompt",
      -- },
      {
        "<Tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return -- "<Tab>" -- fallback
          end
        end,
        mode = { "n" },
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<C-Tab>",
        function()
          if not require("sidekick").clear() then
            return -- "<S-Tab>" -- fallback
          end
        end,
        mode = { "n" },
        expr = true,
        desc = "Close Next Edit Suggestion",
      },
      -- {
      --   "<c-.>",
      --   function()
      --     require("sidekick.cli").toggle()
      --   end,
      --   mode = { "n", "t", "i", "x" },
      --   desc = "Sidekick Toggle",
      -- },
    },
    -- enabled = false,
    opts = {
      cli = {
        tools = {
          claude_yolo = { cmd = { "claude", "--dangerously-skip-permissions" } },
        },
        win = {
          keys = {
            prompt = { "<A-p>", "prompt" },
            -- keep Escape inside the terminal; prevents leaving to Normal mode
            esc = { "<Esc>", "<Esc>", mode = "t", desc = "Sidekick CLI Escape" },
            -- dedicated exit to Normal mode from Sidekick terminal
            stopinsert = { "<C-q>", "stopinsert", mode = "t", desc = "Sidekick CLI stopinsert" },
          },
        },
      },
    },
  },
}
