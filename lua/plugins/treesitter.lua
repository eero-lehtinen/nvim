return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    dependencies = {
      -- Way too much lag to be usable with Rust.
      -- Somewhat lags with other languages like Lua too.
      -- 'HiPhish/rainbow-delimiters.nvim',
    },
    build = ":TSUpdate",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "*" },
        callback = function(ev)
          if not pcall(vim.treesitter.start) then
            require("nvim-treesitter").install({ vim.bo[ev.buf].filetype }):await(function()
              pcall(vim.treesitter.start, ev.buf)
            end)
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
        },
      })

      local keymaps = {
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ai"] = "@conditional.outer", -- [a]round [i]f
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
      }

      local select = require("nvim-treesitter-textobjects.select")

      for k, v in pairs(keymaps) do
        vim.keymap.set({ "o", "x" }, k, function()
          select.select_textobject(v, "textobjects")
        end, { desc = "Select textobject: " .. v })
      end
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      max_lines = 5,
      multiline_threshold = 1,
      on_attach = function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)
        local stat, err = vim.uv.fs_stat(path)
        if not err and stat and stat.size > 100 * 1024 then -- 100kB
          return false
        end
        return true
      end,
    },
  },

  {
    "daliusd/incr.nvim",
    opts = {
      incr_key = "<cr>", -- increment selection key
      decr_key = "<bs>", -- decrement selection key
    },
  },
}
