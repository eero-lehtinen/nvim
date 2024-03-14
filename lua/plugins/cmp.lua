return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = '[[',
          jump_next = ']]',
          accept = '<CR>',
          refresh = 'gr',
          open = false,
          -- open = 'C-ö', -- Cöpailot
        },
        layout = {
          position = 'bottom', -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          next = '<C-¨>', -- actually <C-]>
          prev = '<C-å>', -- actually <C-[>
          dismiss = '<C-ä>', -- below [
          accept = '<C-u>', -- Next to C-y which is normal complete

          -- these work in wezterm, above ones in kitty
          -- next = '<C-]>', -- actually <C-]>
          -- prev = '<C-[>', -- actually <C-[>
          -- dismiss = [[<C-'>]], -- below [, actually ä
          -- accept = '<C-;>', -- accept C[ö]pailot, actually ö
        },
      },
      filetypes = {
        ['*'] = true,
      },
    },
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',

      'hrsh7th/cmp-nvim-lsp',

      'onsails/lspkind.nvim',

      -- (have my own now)
      -- 'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'
      require('luasnip.loaders.from_vscode').lazy_load { paths = { './my-friendly-snippets' } }
      luasnip.config.setup {}

      local compare = require 'cmp.config.compare'
      local types = require 'cmp.types'

      local K = types.lsp.CompletionItemKind
      local kind_order = {
        K.EnumMember,
        K.Field,
        K.Property,
        K.Constant,
        K.Method,
        K.Variable,
        K.Snippet,
        K.Enum,
        K.Function,
        K.Struct,
        K.Constructor,
        K.Class,
        K.Interface,
        K.Module,
        K.Unit,
        K.Value,
        K.Keyword,
        K.Color,
        K.Reference,
        K.Event,
        K.Operator,
        K.TypeParameter,
        K.File,
        K.Folder,
        K.Text,
      }
      local kind_order_map = {}
      for i, k in ipairs(kind_order) do
        kind_order_map[k] = i
      end

      local function my_compare_kind(entry1, entry2)
        local kind1 = kind_order_map[entry1:get_kind()] or 100
        local kind2 = kind_order_map[entry2:get_kind()] or 100
        if kind1 ~= kind2 then
          local diff = kind1 - kind2
          if diff < 0 then
            return true
          elseif diff > 0 then
            return false
          end
        end
        return nil
      end

      ---@diagnostic disable: missing-fields
      cmp.setup {
        sorting = {
          comparators = {
            compare.offset,
            compare.exact,
            -- compare.scopes,
            compare.score,
            compare.recently_used,
            compare.locality,
            my_compare_kind,
            -- compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        -- completion = {
        --   completeopt = 'menu,menuone,noinsert',
        -- },
        preselect = cmp.PreselectMode.None,
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
            menu = {
              buffer = '[Buf]',
              nvim_lsp = '[LSP]',
              luasnip = '[Snip]',
              path = '[Path]',
            },
          },
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping(function(_) -- C-e works by default to close
            if cmp.visible() then
              cmp.abort()
            else
              cmp.complete {}
            end
          end),
          ['<C-y>'] = cmp.mapping.confirm {
            select = true,
            -- behavior = cmp.ConfirmBehavior.Replace,
          },
          ['<C-CR>'] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ['<Tab>'] = cmp.mapping(function(fallback)
            -- if cmp.visible() then
            --   cmp.select_next_item()
            -- else
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            -- if cmp.visible() then
            --   cmp.select_prev_item()
            -- else
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        }),
        experimental = {
          -- ghost_text = { hl_group = 'CmpGhostText' },
        },
      }

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline {
          ['<C-Space>'] = cmp.mapping(function(_)
            if cmp.visible() then
              cmp.abort()
            else
              cmp.complete {}
            end
          end),
          ['<C-y>'] = cmp.mapping.confirm {
            select = true,
          },
        },
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })

      cmp.event:on('menu_opened', function()
        vim.b.copilot_suggestion_hidden = true
        -- require('copilot.suggestion').dismiss()
      end)

      cmp.event:on('menu_closed', function()
        vim.b.copilot_suggestion_hidden = false
        -- require('copilot.suggestion').next()
        -- require('copilot.suggestion').prev()
      end)
    end,
  },
}
