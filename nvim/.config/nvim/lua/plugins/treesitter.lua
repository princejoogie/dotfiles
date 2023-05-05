return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		{
			"windwp/nvim-ts-autotag",
			config = function()
				require("nvim-ts-autotag").setup()
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter-context",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			config = function()
				require("treesitter-context").setup({ enable = true })
			end,
		},
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		{
			"Wansmer/treesj",
			keys = {
				{ "<leader>J", "<cmd>TSJSplit<CR>", desc = "Treesj split" },
				{ "<leader>j", "<cmd>TSJJoin<CR>", desc = "Treesj join" },
			},
			config = function()
				require("treesj").setup()
			end,
		},
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")
		treesitter.setup({
			autotag = {
				enable = true,
				filetypes = {
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"svelte",
					"vue",
					"tsx",
					"jsx",
					"html",
					"rescript",
					"xml",
					"php",
					"markdown",
					"astro",
					"glimmer",
					"handlebars",
					"hbs",
				},
			},
			ensure_installed = {
				"astro",
				"bash",
				"cpp",
				"css",
				"dockerfile",
				"graphql",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"lua",
				"make",
				"markdown",
				"prisma",
				"python",
				"rust",
				"scss",
				"tsx",
				"typescript",
				"yaml",
				"hcl",
				"sql",
			},
			sync_install = false,
			highlight = { enable = true, additional_vim_regex_highlighting = true },
			indent = { enable = true },
			context_commentstring = { enable = true },
			playground = {
				enable = true,
				disable = {},
				updatetime = 25,
				persist_queries = false,
				keybindings = {
					toggle_query_editor = "o",
					toggle_hl_groups = "i",
					toggle_injected_languages = "t",
					toggle_anonymous_nodes = "a",
					toggle_language_display = "I",
					focus_language = "f",
					unfocus_language = "F",
					update = "R",
					goto_node = "<cr>",
					show_help = "?",
				},
			},
		})
	end,
}
