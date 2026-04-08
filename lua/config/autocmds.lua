vim.api.nvim_create_autocmd({ "BufLeave" }, {
  pattern = { "*" },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(bufnr)
    if vim.bo[bufnr].buftype ~= "" or name == "" then
      return
    end
    vim.uv.fs_stat(name, function(err, stat)
      if err or not stat then
        return
      end
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("silent! update")
          end)
        end
      end)
    end)
  end,
  desc = "Autosave on switching buffers",
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

-- Auto-follow terminal output if scrolled to the bottom
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)
    if not bufname:match("claude") then
      return
    end

    local prev_line_count = vim.api.nvim_buf_line_count(buf)

    vim.api.nvim_buf_attach(buf, false, {
      on_lines = function()
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          local cur_win = vim.api.nvim_get_current_win()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf and win ~= cur_win then
              local botline = vim.fn.getwininfo(win)[1].botline
              if prev_line_count <= botline then
                local last_line = vim.api.nvim_buf_line_count(buf)
                vim.api.nvim_win_set_cursor(win, { last_line, 0 })
              end
            end
          end
          prev_line_count = vim.api.nvim_buf_line_count(buf)
        end)
      end,
    })
  end,
})
