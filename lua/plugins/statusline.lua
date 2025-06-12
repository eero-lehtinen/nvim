return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function win_larger_than(n)
        return function()
          return vim.fn.winwidth(0) > n
        end
      end

      local function diff_source()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end

      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_b = { { "b:gitsigns_head", icon = "" }, { "diff", source = diff_source }, "diagnostics" },
          lualine_c = {
            { "filename", path = 1 },
          },
          lualine_x = {
            {
              "encoding",
              cond = win_larger_than(90),
            },
            {
              "fileformat",
              cond = win_larger_than(90),
            },
            { "filetype" },
            {
              "filesize",
              cond = win_larger_than(110),
            },
            {
              function()
                return os.date("%R")
              end,
            },
          },
        },
        extensions = {
          "fugitive",
          "lazy",
          "mason",
          "nvim-dap-ui",
          "nvim-tree",
          "oil",
          "quickfix",
        },
      })
    end,
  },
}
