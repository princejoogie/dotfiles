return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		"mrbjarksen/neo-tree-diagnostics.nvim",
		{
			"s1n7ax/nvim-window-picker",
			config = function()
				require("window-picker").setup()
			end,
		},
	},
	config = function()
		local neotree = require("neo-tree")

		vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
		vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

		neotree.setup({
			sources = {
				"filesystem",
				"git_status",
				"diagnostics",
			},
			source_selector = {
				winbar = true,
				statusline = false,
				sources = {
					{ source = "filesystem", display_name = "   Files " },
					{ source = "git_status", display_name = "   Git " },
					{ source = "diagnostics", display_name = "   Diags " },
				},
			},
			filesystem = {
				follow_current_file = true,
			},
			diagnostics = {
				auto_preview = {
					enabled = false,
					preview_config = {},
					event = "neo_tree_buffer_enter",
				},
				bind_to_cwd = true,
				diag_sort_function = "severity",
				follow_behavior = {
					always_focus_file = false,
					expand_followed = true,
					collapse_others = true,
				},
				follow_current_file = true,
				group_dirs_and_files = true,
				group_empty_dirs = true,
				show_unloaded = true,
				refresh = {
					delay = 100,
					event = "vim_diagnostic_changed",
					max_items = false,
				},
			},
		})
	end,
}
