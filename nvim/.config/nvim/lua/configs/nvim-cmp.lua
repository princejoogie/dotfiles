local stat1, cmp = pcall(require, "cmp")
if (not stat1) then
  return
end

local stat2, lspkind = pcall(require, "lspkind")
if (not stat2) then
  return
end

local M = {}

M.setup = function()
  cmp.setup(
    {
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end
      },
      mapping = {
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), {"i", "c"}),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), {"i", "c"}),
        ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i", "c"}),
        ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i", "c"}),
        ["<C-x>"] = cmp.mapping(cmp.mapping.complete(), {"i", "c"}),
        ["<C-y>"] = cmp.config.disable,
        ["<C-e>"] = cmp.mapping(
          {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close()
          }
        ),
        ["<CR>"] = cmp.mapping.confirm({select = true})
      },
      sources = cmp.config.sources(
        {
          {name = "nvim_lsp"},
          {name = "vsnip"},
          {name = "emoji", insert = true}
        },
        {
          {name = "buffer"},
          {name = "spell"}
        }
      ),
      formatting = {
        format = lspkind.cmp_format(
          {
            mode = "symbol_text",
            maxwidth = 60,
            before = function(_, vim_item)
              return vim_item
            end
          }
        )
      },
      window = {
        completion = {
          border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
        },
        documentation = {
          border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
        }
      }
    }
  )

  -- Set configuration for specific filetype.
  cmp.setup.filetype(
    "gitcommit",
    {
      sources = cmp.config.sources(
        {
          {name = "cmp_git"}
        },
        {
          {name = "buffer"}
        }
      )
    }
  )

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(
    "/",
    {
      sources = {
        {name = "buffer"}
      }
    }
  )

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(
    ":",
    {
      sources = cmp.config.sources(
        {
          {name = "path"}
        },
        {
          {
            name = "cmdline",
            keyword_pattern = [=[[^[:blank:]\!]*]=]
          }
        }
      )
    }
  )
end

return M
