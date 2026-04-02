vim.api.nvim_create_autocmd({ "BufLeave" }, {
  pattern = { "*" },
  callback = function()
    if vim.bo.buftype == "quickfix" then
      return
    end
    vim.cmd("silent! update")
  end,
  desc = "Autosave on switching suffers",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ priority = 1001 })
  end,
})

-- Copied from lazyvim, don't know what it does, I guess checks if the file is changed from the outside
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  command = "checktime",
})

-- Setup justfile syntax
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "justfile",
  callback = function()
    vim.bo.syntax = "sh"
    vim.bo.commentstring = "# %s"
  end,
})

-- Setup wgsl commentstring
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.wgsl",
  callback = function()
    vim.bo.filetype = "wgsl_bevy"
    vim.bo.commentstring = "// %s"
  end,
})

-- Setup ron commentstring
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.ron",
  callback = function()
    vim.bo.commentstring = "// %s"
  end,
})

-- Set formatoptions
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  callback = function()
    vim.opt.formatoptions:remove("o")
    vim.cmd("set signcolumn=yes")
  end,
})

vim.api.nvim_create_augroup("vimrc_incsearch_highlight", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = "vimrc_incsearch_highlight",
  pattern = { "/", "\\?" },
  command = "set hlsearch",
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = "vimrc_incsearch_highlight",
  pattern = { "/", "\\?" },
  command = "set nohlsearch",
})

-- Setup eel syntax
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.eel",
  callback = function()
    vim.schedule(function()
      vim.bo.syntax = "python"
      vim.bo.commentstring = "# %s"
    end)
  end,
})

-- setup gdshader
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.gdshader",
  callback = function()
    vim.schedule(function()
      vim.bo.commentstring = "// %s"
    end)
  end,
})

-- Auto-follow terminal output if cursor was at the bottom
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)
    if not bufname:match("claude") then
      return
    end
    vim.api.nvim_buf_attach(buf, false, {
      on_lines = function(_, _, _, _, _, new_lastline)
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf then
              local cursor = vim.api.nvim_win_get_cursor(win)[1]
              if cursor >= new_lastline - 1 then
                local line_count = vim.api.nvim_buf_line_count(buf)
                pcall(vim.api.nvim_win_set_cursor, win, { line_count, 0 })
              end
            end
          end
        end)
      end,
    })
  end,
})
