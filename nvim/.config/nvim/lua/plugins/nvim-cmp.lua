return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-emoji",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-path",
		"onsails/lspkind.nvim",
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		cmp.setup({
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
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "emoji", insert = true },
				{ name = "path" },
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
						})[entry.source.name]
						return vim_item
					end,
				}),
			},
			window = {
				completion = {
					border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
				},
				documentation = {
					border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
				},
			},
		})

		cmp.setup.filetype("gitcommit", {
			sources = cmp.config.sources({
				{ name = "cmp_git" },
			}, {
				{ name = "buffer" },
			}),
		})

		cmp.setup.cmdline("/", {
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
	end,
}
