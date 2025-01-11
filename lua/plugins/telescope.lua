return {
  "nvim-telescope/telescope.nvim",
  lazy = false,
  -- version = "*",
  enabled = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = vim.g.is_windows
          and 'cmd.exe /c "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"'
        or "make",
    },
  },
  config = function()
    local actions = require("telescope.actions")
    local telescope = require("telescope")

    local ignore_filetypes = { "png", "jpg", "jpeg", "webp", "xcf", "ogg", "mp3", "ttf", "blend" }

    local find_command = { "fd", "--type", "f", "--follow", "--hidden", "-E", ".git" }

    for _, ext in ipairs(ignore_filetypes) do
      table.insert(find_command, "-E")
      table.insert(find_command, "*." .. ext)
    end

    local layout_strategies = require("telescope.pickers.layout_strategies")
    layout_strategies.horizontal_fused = function(picker, max_columns, max_lines, layout_config)
      local layout = layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)
      layout.results.title = ""
      layout.results.height = layout.results.height + 1
      layout.results.line = layout.results.line - 1
      layout.results.borderchars = { "─", "│", "─", "│", "├", "┤", "╯", "╰" }
      return layout
    end

    telescope.setup({
      defaults = {
        layout_strategy = "horizontal_fused",
        path_display = { "truncate" },
        layout_config = {
          prompt_position = "top",
          horizontal = {
            width = 0.9,
            height = 0.9,
            preview_width = 0.5,
          },
          vertical = {
            width = 0.9,
            height = 0.9,
            preview_width = 0.5,
          },
        },
        sorting_strategy = "ascending",
        mappings = {
          i = {
            ["<C-+>"] = actions.which_key,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
            ["<C-h>"] = actions.select_horizontal,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = find_command,
        },
        buffers = {
          mappings = {
            i = {
              ["<C-x>"] = actions.delete_buffer + actions.move_to_top,
            },
            n = {
              ["<C-x>"] = actions.delete_buffer + actions.move_to_top,
            },
          },
        },
      },
      extensions = {
        fzf = {},
      },
    })

    pcall(telescope.load_extension, "fzf")

    local builtin = require("telescope.builtin")

    local function find_all_files()
      builtin.find_files({
        find_command = { "fd", "--type", "f", "--follow", "--hidden", "--no-ignore", "--exclude", ".git" },
      })
    end

    vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })
    vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find existing buffers" })
    vim.keymap.set(
      "n",
      "<leader>/",
      builtin.current_buffer_fuzzy_find,
      { desc = "[/] Fuzzily search in current buffer" }
    )
    vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]earcher (Telescope builtins)" })

    vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sa", find_all_files, { desc = "[S]earch [A]ll Files (Including gitignored)" })
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
    vim.keymap.set("n", "<leader>sd", function()
      builtin.diagnostics({
        severity_limit = vim.diagnostic.severity.INFO,
      })
    end, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sD", function()
      builtin.diagnostics({
        severity_limit = vim.diagnostic.severity.ERROR,
      })
    end, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
    vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>sq", builtin.quickfix, { desc = "[S]earch [Q]uickfix" })
    vim.keymap.set("n", "<leader>sl", builtin.loclist, { desc = "[S]earch [L]oclist" })

    vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Search [G]it [S]tatus" })
  end,
}
