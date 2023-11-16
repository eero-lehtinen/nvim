return {
  'nvim-telescope/telescope.nvim',
  -- branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'debugloop/telescope-undo.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    'MunifTanjim/nui.nvim',
  },
  config = function()
    local actions = require 'telescope.actions'

    local Layout = require 'nui.layout'
    local Popup = require 'nui.popup'

    local telescope = require 'telescope'
    local TSLayout = require 'telescope.pickers.layout'

    local function make_popup(options)
      local popup = Popup(options)
      ---@diagnostic disable-next-line: inject-field
      function popup.border:change_title(title)
        popup.border.set_text(popup.border, 'top', title)
      end
      ---@diagnostic disable-next-line: param-type-mismatch
      return TSLayout.Window(popup)
    end

    telescope.setup {
      defaults = {
        layout_strategy = 'flex',
        layout_config = {
          horizontal = {
            size = {
              width = '90%',
              height = '60%',
            },
          },
          vertical = {
            size = {
              width = '90%',
              height = '90%',
            },
          },
        },
        create_layout = function(picker)
          local border = {
            prompt = {
              top_left = '┌',
              top = '─',
              top_right = '┬',
              right = '│',
              bottom_right = '',
              bottom = '',
              bottom_left = '',
              left = '│',
            },
            prompt_patch = {
              minimal = {
                top_left = '┌',
                top_right = '┐',
              },
              horizontal = {
                top_left = '┌',
                top_right = '┬',
              },
              vertical = {
                top_left = '├',
                top_right = '┤',
              },
            },
            results = {
              top_left = '├',
              top = '─',
              top_right = '┤',
              right = '│',
              bottom_right = '┘',
              bottom = '─',
              bottom_left = '└',
              left = '│',
            },
            results_patch = {
              minimal = {
                bottom_right = '┘',
              },
              horizontal = {
                bottom_right = '┴',
              },
              vertical = {
                bottom_right = '┘',
              },
            },
            preview = {
              top_left = '┌',
              top = '─',
              top_right = '┐',
              right = '│',
              bottom_right = '┘',
              bottom = '─',
              bottom_left = '└',
              left = '│',
            },
            preview_patch = {
              minimal = {},
              horizontal = {
                bottom = '─',
                bottom_left = '',
                bottom_right = '┘',
                left = '',
                top_left = '',
              },
              vertical = {
                bottom = '',
                bottom_left = '',
                bottom_right = '',
                left = '│',
                top_left = '┌',
              },
            },
          }

          local results = make_popup {
            focusable = false,
            border = {
              style = border.results,
              text = {
                top = picker.results_title,
                top_align = 'center',
              },
            },
            win_options = {
              winhighlight = 'Normal:Normal,FloatBorder:TelescopeBorder,FloatTitle:TelescopeResultsTitle',
            },
          }

          local prompt = make_popup {
            enter = true,
            border = {
              style = border.prompt,
              text = {
                top = picker.prompt_title,
                top_align = 'center',
              },
            },
            win_options = {
              winhighlight = 'Normal:Normal,FloatBorder:TelescopeBorder,FloatTitle:TelescopePromptTitle',
            },
          }

          local preview = make_popup {
            focusable = false,
            border = {
              style = border.preview,
              text = {
                top = picker.preview_title,
                top_align = 'center',
              },
            },
            win_options = {
              winhighlight = 'Normal:Normal,FloatBorder:TelescopeBorder,FloatTitle:TelescopePreviewTitle',
            },
          }

          local box_by_kind = {
            vertical = Layout.Box({
              Layout.Box(preview, { grow = 1 }),
              Layout.Box(prompt, { size = 2 }),
              Layout.Box(results, { grow = 1 }),
            }, { dir = 'col' }),
            horizontal = Layout.Box({
              Layout.Box({
                Layout.Box(prompt, { size = 2 }),
                Layout.Box(results, { grow = 1 }),
              }, { dir = 'col', size = '50%' }),
              Layout.Box(preview, { size = '50%' }),
            }, { dir = 'row' }),
            minimal = Layout.Box({
              Layout.Box(prompt, { size = 2 }),
              Layout.Box(results, { grow = 1 }),
            }, { dir = 'col' }),
          }

          local function get_box()
            local strategy = picker.layout_strategy
            if strategy == 'vertical' or strategy == 'horizontal' then
              return box_by_kind[strategy], strategy
            end

            local height, width = vim.o.lines, vim.o.columns
            local box_kind = 'horizontal'
            if width < 120 then
              box_kind = 'vertical'
              if height < 40 then
                box_kind = 'minimal'
              end
            end

            if picker.prompt_title == 'Current Buffer Fuzzy' then
              box_kind = 'minimal'
            end

            return box_by_kind[box_kind], box_kind
          end

          local function prepare_layout_parts(layout, box_type)
            layout.results = results
            ---@diagnostic disable-next-line: undefined-field
            results.border:set_style(border.results_patch[box_type])

            layout.prompt = prompt
            ---@diagnostic disable-next-line: undefined-field
            prompt.border:set_style(border.prompt_patch[box_type])

            if box_type == 'minimal' then
              layout.preview = nil
            else
              layout.preview = preview
              ---@diagnostic disable-next-line: undefined-field
              preview.border:set_style(border.preview_patch[box_type])
            end
          end

          local function get_layout_size(box_kind)
            if picker.prompt_title == 'Current Buffer Fuzzy' then
              return {
                width = '90%',
                height = '60%',
              }
            end
            return picker.layout_config[box_kind == 'minimal' and 'vertical' or box_kind].size
          end

          local box, box_kind = get_box()
          local layout = Layout({
            relative = 'editor',
            position = '50%',
            size = get_layout_size(box_kind),
          }, box)

          ---@diagnostic disable-next-line: inject-field
          layout.picker = picker
          prepare_layout_parts(layout, box_kind)

          local layout_update = layout.update
          ---@diagnostic disable-next-line: duplicate-set-field
          function layout:update()
            ---@diagnostic disable-next-line: redefined-local
            local box, box_kind = get_box()
            prepare_layout_parts(layout, box_kind)
            layout_update(self, { size = get_layout_size(box_kind) }, box)
          end

          ---@diagnostic disable-next-line: param-type-mismatch
          return TSLayout(layout)
        end,
        sorting_strategy = 'ascending',
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
        },
        buffers = {
          sort_lastused = true,
          mappings = {
            i = {
              ['<C-d>'] = actions.delete_buffer + actions.move_to_top,
            },
          },
        },
      },
      extensions = {
        undo = {
          -- side_by_side = true,
          layout_strategy = 'vertical',
          layout_config = {
            preview_height = 0.7,
          },
        },
        media_files = {
          find_cmd = 'rg',
        },
      },
    }

    pcall(telescope.load_extension, 'fzf')
    telescope.load_extension 'undo'

    local builtin = require 'telescope.builtin'

    vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch [T]elescope' })

    vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', function()
      builtin.diagnostics {
        severity_limit = vim.diagnostic.severity.INFO,
      }
    end, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>su', telescope.extensions.undo.undo, { desc = '[S]earch [U]ndo tree' })
  end,
}
