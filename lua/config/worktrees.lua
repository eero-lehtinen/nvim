local M = {}

local function parse_worktrees(output)
  local worktrees = {}
  local worktree

  for _, field in ipairs(vim.split(output, "\0", { plain = true, trimempty = false })) do
    if field == "" then
      if worktree then
        worktrees[#worktrees + 1] = worktree
        worktree = nil
      end
    else
      local key, value = field:match("^(%S+)%s?(.*)$")
      if key == "worktree" then
        worktree = { path = value }
      elseif worktree then
        worktree[key] = value ~= "" and value or true
      end
    end
  end

  return worktrees
end

local function picker_items(worktrees)
  local items = {}
  for _, worktree in ipairs(worktrees) do
    if not worktree.prunable then
      local branch = worktree.branch and worktree.branch:gsub("^refs/heads/", "")
        or (worktree.detached and "detached")
        or "bare"
      items[#items + 1] = {
        text = branch .. " " .. worktree.path,
        branch = branch,
        path = worktree.path,
      }
    end
  end
  return items
end

local function path_relative_to(path, root)
  path = vim.fs.normalize(path)
  root = vim.fs.normalize(root)

  local comparable_path = jit.os == "Windows" and path:lower() or path
  local comparable_root = jit.os == "Windows" and root:lower() or root
  if comparable_path == comparable_root then
    return ""
  end

  local prefix = comparable_root:gsub("/$", "") .. "/"
  if comparable_path:sub(1, #prefix) ~= prefix then
    return nil
  end

  return path:sub(#prefix + 1)
end

local function current_worktree_path(worktrees)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local current

  for _, worktree in ipairs(worktrees) do
    if path_relative_to(cwd, worktree.path) ~= nil and (not current or #worktree.path > #current) then
      current = worktree.path
    end
  end

  return current
end

local function retarget_buffers(source_root, target_root)
  if not source_root or vim.fs.normalize(source_root) == vim.fs.normalize(target_root) then
    return 0, 0
  end

  local retargeted = 0
  local skipped = 0

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    local relative = name ~= "" and path_relative_to(name, source_root) or nil

    if relative and relative ~= "" and vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == "" then
      if vim.bo[bufnr].modified then
        skipped = skipped + 1
      else
        local target = vim.fs.joinpath(target_root, relative)
        local target_bufnr = vim.fn.bufnr(target)

        if target_bufnr ~= -1 and target_bufnr ~= bufnr then
          for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
            vim.api.nvim_win_set_buf(winid, target_bufnr)
          end
          vim.api.nvim_buf_delete(bufnr, {})
        else
          vim.api.nvim_buf_set_name(bufnr, target)
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd.edit({ bang = true })
          end)
        end

        retargeted = retargeted + 1
      end
    end
  end

  return retargeted, skipped
end

function M.pick()
  vim.system(
    { "git", "-C", vim.fn.getcwd(), "worktree", "list", "--porcelain", "-z" },
    { text = true },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local message = vim.trim(result.stderr or "")
          vim.notify(message ~= "" and message or "Could not list git worktrees", vim.log.levels.ERROR, {
            title = "Worktree",
          })
          return
        end

        local worktrees = parse_worktrees(result.stdout or "")
        local source_root = current_worktree_path(worktrees)
        local items = picker_items(worktrees)
        for _, item in ipairs(items) do
          item.current = source_root ~= nil and path_relative_to(item.path, source_root) == ""
        end
        if #items == 0 then
          vim.notify("No git worktrees found", vim.log.levels.WARN, { title = "Worktree" })
          return
        end

        Snacks.picker.pick({
          title = "Git Worktrees",
          items = items,
          format = function(item)
            return {
              { item.current and "● " or "  ", item.current and "DiagnosticOk" or "Normal" },
              { item.branch, "SnacksPickerLabel" },
              { item.current and "  (current)" or "", "Comment" },
              { "  " },
              { item.path, "SnacksPickerDirectory" },
            }
          end,
          confirm = function(picker, item)
            if not item then
              return
            end
            local ok, err = pcall(vim.cmd.cd, vim.fn.fnameescape(item.path))
            if not ok then
              vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Worktree" })
              return
            end
            local retargeted, skipped = retarget_buffers(source_root, item.path)
            picker:close()
            local message = ("cwd: %s (%d buffers retargeted)"):format(item.path, retargeted)
            if skipped > 0 then
              message = message .. ("; %d modified buffers kept on their original paths"):format(skipped)
            end
            vim.notify(message, skipped > 0 and vim.log.levels.WARN or vim.log.levels.INFO, { title = "Worktree" })
          end,
        })
      end)
    end
  )
end

return M
