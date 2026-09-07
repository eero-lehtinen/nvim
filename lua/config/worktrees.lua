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

        local items = picker_items(parse_worktrees(result.stdout or ""))
        if #items == 0 then
          vim.notify("No git worktrees found", vim.log.levels.WARN, { title = "Worktree" })
          return
        end

        Snacks.picker.pick({
          title = "Git Worktrees",
          items = items,
          format = function(item)
            return {
              { item.branch, "SnacksPickerLabel" },
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
            picker:close()
            vim.notify("cwd: " .. item.path, vim.log.levels.INFO, { title = "Worktree" })
          end,
        })
      end)
    end
  )
end

return M
