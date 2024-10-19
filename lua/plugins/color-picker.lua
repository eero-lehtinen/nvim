return {
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    build = 'download.lua',
    config = function()
      require('oklch-color-picker').setup {}
      vim.keymap.set('n', '<leader>v', '<cmd>ColorPickOklch<cr>')
    end,
  },
}
