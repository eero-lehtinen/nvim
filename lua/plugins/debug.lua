-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Creates a beautiful debugger UI
    "rcarriga/nvim-dap-ui",

    "nvim-neotest/nvim-nio",

    -- Installs the debug adapters for you
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",

    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {
        virt_text_pos = "eol",
      },
    },

    -- Add your own debuggers here
    "leoluz/nvim-dap-go",
  },
  event = "VeryLazy",
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_installation = false,
      ensure_installed = {
        "delve",
        "codelldb",
      },
      handlers = {},
    })

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
    vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Set Breakpoint with condition" })
    vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Debug: Quit" })
    vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })

    -- For more information, see |:help nvim-dap-ui|
    ---@diagnostic disable: missing-fields
    dapui.setup({})

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "Debug: Toggle" })
    vim.keymap.set(
      { "n", "v" },
      "<leader>de",
      dapui.eval,
      { desc = "Debug: Eval (View data of the selected variable)" }
    )

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close

    --  CPP / C config
    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        -- Probably should manually override for each project
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
      },
    }
    dap.configurations.c = dap.configurations.cpp

    -- Install golang specific config
    require("dap-go").setup()
  end,
}
