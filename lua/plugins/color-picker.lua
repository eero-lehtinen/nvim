return {
  {
    -- 'eero-lehtinen/oklch-color-picker.nvim',
    dir = '~/repos/oklch-color-picker.nvim',
    build = 'download.lua',
    config = function()
      require('oklch-color-picker').setup {
        -- log_level = vim.log.levels.DEBUG,
      }

      -- Color::new(0.8748, 0.1816, 0.9064)
      vim.keymap.set('n', '<leader>p', require('oklch-color-picker').pick_under_cursor)
    end,
  },
}
