return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
      "kristijanhusak/vim-dadbod-completion",
    },
    opts = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      return {
        -- completion = {
        --   autocomplete = false,
        -- },
        mapping = {
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<C-x>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
          { name = "vim-dadbod-completion" },
          { name = "git" },
          { name = "path" },
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "lazydev", group_index = 0 },
        }, {
          { name = "buffer" },
          { name = "spell" },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = lspkind.cmp_format({
            mode = "symbol",
            preset = "codicons",
            maxwidth = 50,
            before = function(entry, vim_item)
              vim_item.menu = ({
                nvim_lsp = "[LSP ]",
                buffer = "[Buf ]",
                path = "[Path]",
                luasnip = "[Snip]",
                git = "[Git ]",
                ["vim-dadbod-completion"] = "[DB  ]",
              })[entry.source.name]

              return vim_item
            end,
          }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      }
    end,
    config = function(_, opts)
      local cmp = require("cmp")

      cmp.setup.filetype("sql", {
        sources = cmp.config.sources({
          { name = "vim-dadbod-completion" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "git" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end

      cmp.setup(opts)
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "nvim-cmp",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
        },
        opts = function(_, opts)
          opts.snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          }
          table.insert(opts.sources, { name = "luasnip" })
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "petertriho/cmp-git",
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = {},
    init = function()
      table.insert(require("cmp").get_config().sources, { name = "git" })
    end,
  },
  {
    "princejoogie/supermaven-nvim",
    enabled = false,
    dir = "~/documents/codes/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },
}
