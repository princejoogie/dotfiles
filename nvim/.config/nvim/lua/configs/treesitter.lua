local treesitter = safe_require("nvim-treesitter.configs")
if not treesitter then
	return
end

local M = {}

M.setup = function()
	treesitter.setup({
		ensure_installed = {
			"astro",
			"bash",
			"cpp",
			"css",
			"dockerfile",
			"go",
			"graphql",
			"html",
			"help",
			"javascript",
			"jsdoc",
			"json",
			"json5",
			"lua",
			"make",
			"markdown",
			"prisma",
			"python",
			"rust",
			"scss",
			"solidity",
			"svelte",
			"tsx",
			"typescript",
			"vim",
			"yaml",
			"hcl",
			"java",
			"sql",
		},
		sync_install = true,
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
end

return M
