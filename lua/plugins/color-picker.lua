return {
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    -- dev = true,
    config = function()
      require('oklch-color-picker').setup {}
      vim.keymap.set('n', '<leader>v', '<cmd>ColorPickOklch<cr>')
    end,
  },
}
