-- Dictation tools (ChatGPT etc.) insert text by setting the clipboard and
-- sending Ctrl+V. Treat Ctrl+V as paste only when the clipboard changed while
-- nvim was focused and the content isn't nvim's own last yank; otherwise keep
-- the builtin visual-block / literal-insert behavior.
local M = {}

local ffi = require("ffi")
ffi.cdef("uint32_t GetClipboardSequenceNumber(void);")
local user32 = ffi.load("user32")

local seen_seq = 0
local own_text

local function seq()
  return user32.GetClipboardSequenceNumber()
end

local function mark_seen()
  seen_seq = seq()
end

local function normalize(s)
  return (s:gsub("\r", ""):gsub("\n+$", ""))
end

function M.paste()
  local text = vim.fn.getreg("+")
  if normalize(text) == own_text then
    vim.api.nvim_feedkeys(vim.keycode("<C-v>"), "n", false)
    return
  end
  vim.api.nvim_paste(text, true, -1)
  -- Some dictation tools restore the previous clipboard right after pasting.
  vim.defer_fn(mark_seen, 1000)
end

function M.setup()
  mark_seen()

  local group = vim.api.nvim_create_augroup("dictation-paste", { clear = true })
  vim.api.nvim_create_autocmd("FocusGained", { group = group, callback = mark_seen })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
      own_text = normalize(table.concat(vim.v.event.regcontents, "\n"))
    end,
  })

  vim.keymap.set({ "n", "i", "c", "t" }, "<C-v>", function()
    local s = seq()
    if s == seen_seq then
      return "<C-v>"
    end
    seen_seq = s
    return "<Cmd>lua require('config.dictation-paste').paste()<CR>"
  end, { expr = true, desc = "Visual block, or paste text from dictation tools" })
end

return M
