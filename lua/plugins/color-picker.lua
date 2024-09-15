return {
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    dev = false,
    build = 'download.lua',
    keys = {
      {
        '<leader>p',
        function()
          require('oklch-color-picker').pick_under_cursor()
        end,
        desc = '[P]ick color',
      },
    },
    cmd = 'ColorPickOklch',
    opts = {},
  },
}
