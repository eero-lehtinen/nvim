return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local function win_larger_than(n)
        return function()
          return vim.fn.winwidth(0) > n
        end
      end
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = '',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            { 'filename', path = 1 },
          },
          lualine_x = {
            {
              'encoding',
              cond = win_larger_than(90),
            },
            {
              'fileformat',
              cond = win_larger_than(90),
            },
            { 'filetype' },
            {
              'filesize',
              cond = win_larger_than(110),
            },
          },
        },
        extensions = {
          'fugitive',
          'lazy',
          'mason',
          'nvim-dap-ui',
          'nvim-tree',
          'quickfix',
        },
      }
    end,
  },
}
