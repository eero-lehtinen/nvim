return {
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    -- dev = true,
    build = 'download.lua',
    keys = {
      {
        '<leader>v',
        function()
          require('oklch-color-picker').pick_under_cursor()
        end,
        desc = 'Pick color',
      },
    },
    cmd = 'ColorPickOklch',
    opts = {},
  },
}
