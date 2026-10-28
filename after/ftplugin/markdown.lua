local fallback = vim.fn.maparg("gx", "n", false, true).callback

vim.keymap.set("n", "gx", function()
  if not require("config.markdown-links").follow() and fallback then
    fallback()
  end
end, { buffer = true, desc = "Follow Markdown link" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "\nsilent! nunmap <buffer> gx"
