require("vim._core.ui2").enable({})

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>u", function()
  require("undotree").open({ command = "70vnew" })
end, { desc = "Open [U]ndotree" })

vim.cmd("packadd nvim.difftool")
