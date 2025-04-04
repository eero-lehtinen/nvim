return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    init = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = false,
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4,
          },
        },
        suggestion = {
          auto_trigger = true,
          keymap = {
            -- next = "<C-¨>", -- actually <C-]>
            -- prev = "<C-å>", -- actually <C-[>
            -- dismiss = "<C-ä>", -- below [
            -- accept = "<C-a>",
            -- accept = "<C-u>", -- Next to C-y which is normal complete

            next = "<M-n>",
            prev = "<M-p>",
            accept = "<C-u>",
            dismiss = "<M-e>",
          },
        },
        filetypes = {
          ["*"] = true,
        },
        copilot_model = "gpt-4o-copilot",
        server = {
          type = "binary",
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
    "Exafunction/codeium.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
    enabled = false,
    config = function()
      require("codeium").setup({
        enable_cmp_source = false,
        virtual_text = {
          enabled = true,
          manual = true,
          key_bindings = {
            accept = "<C-u>",
            next = "<M-n>",
            prev = "<M-p>",
            dismiss = "<M-e>",
          },
        },
      })

      vim.keymap.set("n", "<leader>ta", function()
        local virtual_text = require("codeium.config").options.virtual_text
        virtual_text.manual = not virtual_text.manual
        if not virtual_text.manual then
          vim.notify("Codeium enabled")
        else
          vim.notify("Codeium disabled")
        end
      end, { desc = "[T]oggle [A]I Codeium" })
    end,
  },

  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    enabled = false,
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-u>",
          clear_suggestion = "<C-¨>", -- actually <C-]>
          accept_word = "<F24>",
        },
        color = {
          suggestion_color = "#739296",
          cterm = 244,
        },
        log_level = "off",
      })

      local api = require("supermaven-nvim.api")
      vim.keymap.set("n", "<leader>ta", function()
        if api.is_running() then
          vim.notify("Supermaven disabled")
        else
          vim.notify("Supermaven enabled")
        end

        api.toggle()
      end, { desc = "[T]oggle [A]I SuperMaven" })

      api.stop()
    end,
  },
}
