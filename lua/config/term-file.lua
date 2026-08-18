-- Open file references printed in a terminal buffer (Claude, test runners,
-- compilers) in a real editor window.

local M = {}

-- Terminal output wraps paths in punctuation, box drawing and markdown ticks.
-- A leading backslash is kept for UNC paths like \\server\share\a.lua.
local function strip(token)
  local text = token:gsub("^[^%w%./~_%-%$\\]+", ""):gsub("[^%w%)%]]+$", "")
  -- Closing brackets only count as junk when unmatched, e.g. "(src/a.lua)".
  if text:sub(-1) == ")" and not text:find("%(") then
    text = text:sub(1, -2)
  end
  if text:sub(-1) == "]" and not text:find("%[") then
    text = text:sub(1, -2)
  end
  return text
end

---Interpretations of a token, most specific first. A Windows drive letter or a
---file name ending in digits can look like a ":line" suffix, so the bare token
---is always kept as a fallback.
---@return { path: string, lnum: integer?, col: integer? }[]
local function interpretations(text)
  local out = {}
  local path, lnum, col = text:match("^(.+):(%d+):(%d+)$")
  if path then
    out[#out + 1] = { path = path, lnum = tonumber(lnum), col = tonumber(col) }
  end
  path, lnum = text:match("^(.+):(%d+)$")
  if path then
    out[#out + 1] = { path = path, lnum = tonumber(lnum) }
  end
  -- GitHub style: src/main.rs#L42
  path, lnum = text:match("^(.+)#L(%d+)$")
  if path then
    out[#out + 1] = { path = path, lnum = tonumber(lnum) }
  end
  out[#out + 1] = { path = text }
  return out
end

-- vim.fs.normalize only rewrites backslashes on Windows; elsewhere they are
-- ordinary file name characters, so both separators are accepted here.
local function is_absolute(path)
  return path:match("^[/\\]") ~= nil or path:match("^%a:[/\\]") ~= nil
end

local function resolve(path)
  if path == "" then
    return nil
  end
  local expanded = vim.fs.normalize(path)
  local roots = is_absolute(expanded) and { "" } or { vim.fs.normalize(vim.fn.getcwd()), vim.fs.root(0, ".git") }
  for _, root in ipairs(roots) do
    local full = root == "" and expanded or (root .. "/" .. expanded)
    local stat = vim.uv.fs_stat(full)
    if stat and stat.type == "file" then
      return full
    end
  end
end

---@return { file: string, lnum: integer?, col: integer? }?
local function parse(token)
  for _, ref in ipairs(interpretations(strip(token))) do
    local file = resolve(ref.path)
    if file then
      return { file = file, lnum = ref.lnum, col = ref.col }
    end
  end
end

---Whitespace-delimited tokens on a line, with their spans.
---@return { s: integer, e: integer, text: string }[]
local function tokens(line)
  local out = {}
  local init = 1
  while true do
    local s, e = line:find("%S+", init)
    if not s then
      return out
    end
    out[#out + 1] = { s = s, e = e, text = line:sub(s, e) }
    init = e + 1
  end
end

local function line_at(buf, lnum)
  return vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
end

---Fragments of a wrapped token continuing away from `lnum` in `step` direction,
---shortest first. Walking past the neighbour only makes sense while it holds a
---single token, which is what a path spanning three or more lines looks like.
---@return string[]
local function wrap_fragments(buf, lnum, step)
  local out, acc, n = {}, "", lnum
  for _ = 1, 3 do
    n = n + step
    local line = line_at(buf, n)
    if not line then
      break
    end
    local toks = tokens(line)
    if #toks == 0 then
      break
    end
    local text = (step < 0 and toks[#toks] or toks[1]).text
    acc = step < 0 and (text .. acc) or (acc .. text)
    out[#out + 1] = acc
    if #toks > 1 then
      break
    end
  end
  return out
end

---Token containing the cursor, plus rejoined variants for paths the terminal
---hard-wrapped at the window edge. Leading and trailing whitespace is ignored
---when deciding whether a token sits against an edge, so a padded or trimmed
---line still counts. Gluing on a neighbour cannot open a wrong file: every
---candidate has to resolve to a file that exists.
---@return string[] candidates Fewest joins first.
local function candidates_under_cursor(buf, lnum, col)
  local line = line_at(buf, lnum)
  if not line then
    return {}
  end
  local toks = tokens(line)
  local idx
  for i, tok in ipairs(toks) do
    if tok.s <= col and col <= tok.e then
      idx = i
      break
    end
  end
  if not idx then
    return {}
  end

  local pre = idx == 1 and wrap_fragments(buf, lnum, -1) or {}
  local suf = idx == #toks and wrap_fragments(buf, lnum, 1) or {}
  local out = {}
  for total = 0, #pre + #suf do
    for np = math.max(0, total - #suf), math.min(total, #pre) do
      local ns = total - np
      out[#out + 1] = (np > 0 and pre[np] or "") .. toks[idx].text .. (ns > 0 and suf[ns] or "")
    end
  end
  return out
end

local function is_editable(win)
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
end

local function target_window()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if prev ~= 0 and vim.api.nvim_win_is_valid(prev) and is_editable(prev) then
    return prev
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= vim.api.nvim_get_current_win() and is_editable(win) then
      return win
    end
  end
  vim.cmd("vsplit")
  return vim.api.nvim_get_current_win()
end

---Open the file reference under the cursor in another window.
function M.open()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local candidates = candidates_under_cursor(vim.api.nvim_get_current_buf(), cursor[1], cursor[2] + 1)
  local ref
  for _, candidate in ipairs(candidates) do
    ref = parse(candidate)
    if ref then
      break
    end
  end
  if not ref then
    vim.notify("No file under cursor: " .. (candidates[1] or ""), vim.log.levels.WARN)
    return
  end

  local win = target_window()
  vim.api.nvim_set_current_win(win)
  vim.cmd.edit(vim.fn.fnameescape(ref.file))
  if ref.lnum then
    vim.api.nvim_win_set_cursor(win, { math.min(ref.lnum, vim.api.nvim_buf_line_count(0)), (ref.col or 1) - 1 })
    vim.cmd("normal! zz")
  end
end

return M
