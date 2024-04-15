return {
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		config = function()
			vim.g.startuptime_tries = 10
		end,
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = { options = vim.opt.sessionoptions:get() },
		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "Restore Session",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore Last Session",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "Don't Save Current Session",
			},
		},
	},
	{ "nvim-lua/plenary.nvim", lazy = true },
	{
		"folke/neodev.nvim",
		dependencies = { "nvim-neotest/neotest" },
		config = function()
			require("neodev").setup({
				library = { plugins = { "neotest" }, types = true },
			})
		end,
	},
	{
		"aserowy/tmux.nvim",
		opts = {
			resize = {
				resize_step_x = 5,
				resize_step_y = 5,
			},
		},
	},
	{ "levouh/tint.nvim", opts = { tint = -50 } },
	{
		"diepm/vim-rest-console",
		config = function()
			vim.g.vrc_response_default_content_type = "application/json"
			vim.g.vrc_output_buffer_name = "__VRC_OUTPUT__"
			vim.g.vrc_auto_format_response_patterns = {
				json = "jq",
			}
		end,
	},
}
