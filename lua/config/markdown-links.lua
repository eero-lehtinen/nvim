local M = {}
local ts = vim.treesitter

local function warn(message)
  vim.notify(message, vim.log.levels.WARN, { title = "Markdown link" })
end

local function child_text(node, kind)
  for child in node:iter_children() do
    if child:type() == kind then
      return ts.get_node_text(child, 0)
    end
  end
end

local function label(text)
  local normalized = vim.trim(text:gsub("^%[", ""):gsub("%]$", "")):gsub("%s+", " ")
  return vim.fn.tolower(normalized)
end

local function destination()
  local parser = assert(ts.get_parser(0, "markdown"), "Markdown parser unavailable")
  parser:parse(true)
  local block = ts.get_node({ ignore_injections = true })
  while block do
    if block:type() == "fenced_code_block" or block:type() == "indented_code_block" then
      return
    end
    block = block:parent()
  end
  local node = ts.get_node({ ignore_injections = false })
  while node do
    local kind = node:type()
    local target = child_text(node, "link_destination")
    if target then
      return target
    elseif kind == "uri_autolink" or kind == "email_autolink" then
      target = ts.get_node_text(node, 0):sub(2, -2)
      return kind == "email_autolink" and ("mailto:" .. target) or target
    elseif kind == "full_reference_link" or kind == "collapsed_reference_link" or kind == "shortcut_link" then
      local name = child_text(node, "link_label") or child_text(node, "link_text")
      local query = ts.query.parse(
        "markdown",
        [[
        (link_reference_definition (link_label) @label (link_destination) @target)
      ]]
      )
      for _, tree in ipairs(parser:trees()) do
        for _, match in query:iter_matches(tree:root(), 0) do
          if label(ts.get_node_text(match[1][1], 0)) == label(name) then
            return ts.get_node_text(match[2][1], 0)
          end
        end
      end
      error("Undefined reference: " .. name, 0)
    end
    node = node:parent()
  end
end

local function open_external(target)
  local process, err = vim.ui.open(target)
  if not process then
    error(err, 0)
  end
  -- A launcher can outlive its application startup. Check without blocking.
  local function check()
    if not process:is_closing() then
      vim.defer_fn(check, 500)
    elseif process:wait().code ~= 0 then
      warn("Opener failed: " .. target)
    end
  end
  vim.defer_fn(check, 100)
end

local function heading(fragment)
  if fragment:match("^L%d+$") then
    return tonumber(fragment:sub(2))
  end
  local query = ts.query.parse(
    "markdown",
    [[
    [(atx_heading heading_content: (_) @text)
     (setext_heading heading_content: (_) @text)]
  ]]
  )
  local used = {}
  local parser = assert(ts.get_parser(0, "markdown"), "Markdown parser unavailable")
  local trees = assert(parser:parse(true), "Markdown parsing did not complete")
  for _, tree in ipairs(trees) do
    for _, node in query:iter_captures(tree:root(), 0) do
      local title = ts.get_node_text(node, 0)
      local explicit = title:match("{#([^}]+)}%s*$")
      title = title:gsub("%s*{#[^}]+}%s*$", ""):gsub("<[^>]->", ""):gsub("%[([^%]]+)%]%([^%)]*%)", "%1")
      local base = vim.fn.tolower(title):gsub("[!\"#$%%&'()*+,./:;<=>?@%[\\%]%^`{|}~]", "")
      base = vim.trim(base):gsub("%s", "-")
      local slug, suffix = base, 0
      while used[slug] do
        suffix = suffix + 1
        slug = base .. "-" .. suffix
      end
      used[slug] = true
      if slug == vim.fn.tolower(fragment) or explicit == fragment then
        return node:start() + 1
      end
    end
  end
  error("Heading not found: " .. fragment, 0)
end

local function follow()
  local target = destination()
  if not target then
    return false
  end
  target = target:gsub("^<", ""):gsub(">$", ""):gsub("\\([%p])", "%1")
  if target:match("^man://") then
    vim.cmd.Man({ target:sub(7) })
    return true
  elseif not target:match("^file:") and (target:match("^%a[%w+.-]*://") or target:match("^mailto:")) then
    open_external(target)
    return true
  end

  -- Decode after splitting: %23 belongs to the filename, not the fragment.
  local path, fragment = target:match("^([^#]*)#(.*)$")
  path = path or target
  local row, col
  if path ~= "" then
    path = path:match("^file:") and vim.uri_to_fname(path) or vim.uri_decode(path)
    path = vim.fs.normalize(path, { expand_env = false })
    if path:sub(1, 1) ~= "/" then
      path = vim.fs.joinpath(vim.fn.expand("%:p:h"), path)
    end
    if not vim.uv.fs_stat(path) then
      local file, line, column = path:match("^(.-):(%d+):(%d+)$")
      if not file then
        file, line = path:match("^(.-):(%d+)$")
      end
      path, row, col = file or path, tonumber(line), tonumber(column)
    end
    if not vim.uv.fs_stat(path) and vim.uv.fs_stat(path .. ".md") then
      path = path .. ".md"
    end
    if not vim.uv.fs_stat(path) then
      error("File not found: " .. path, 0)
    end
  end

  vim.cmd("normal! m'")
  if path ~= "" then
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
  if fragment and fragment ~= "" then
    row = heading(vim.uri_decode(fragment))
  end
  if row then
    row = math.max(1, math.min(row, vim.api.nvim_buf_line_count(0)))
    col = math.max(0, math.min((col or 1) - 1, #vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]))
    vim.api.nvim_win_set_cursor(0, { row, col })
    vim.cmd("normal! zvzz")
  end
  return true
end

---Return false outside Markdown links so the mapping can fall back to native gx.
function M.follow()
  local ok, handled = pcall(follow)
  if not ok then
    warn(tostring(handled))
  end
  return not ok or handled
end

return M
