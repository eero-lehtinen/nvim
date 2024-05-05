return {
  {
    'nvim-treesitter/nvim-treesitter',
    commit = 'c1d1b4084ef5239e2671f64d35962d184251aea4', -- downgrade for now
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      -- Way too much lag to be usable with Rust.
      -- Somewhat lags with other languages like Lua too.
      -- 'HiPhish/rainbow-delimiters.nvim',
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
          max_lines = 5,
          multiline_threshold = 1,
        },
      },
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = {
          'c',
          'cpp',
          'go',
          'lua',
          'python',
          'rust',
          'tsx',
          'typescript',
          'vimdoc',
          'vim',
          'html',
          'javascript',
          'css',
          'regex',
          'bash',
          'fish',
          'markdown',
          'markdown_inline',
        },

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = true,

        sync_install = false,
        ignore_install = {},
        modules = {},

        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },

        matchup = {
          enable = true,
        },

        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-n>',
            node_incremental = '<C-n>',
            node_decremental = '<C-m>',
            -- scope_incremental = '<A-v>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['ai'] = '@conditional.outer', -- [a]round [i]f
              ['ii'] = '@conditional.inner',
              ['al'] = '@loop.outer',
              ['il'] = '@loop.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      }
    end,
  },
}
