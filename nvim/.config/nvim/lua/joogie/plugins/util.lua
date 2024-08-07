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
				"<leader>ws",
				function()
					require("persistence").load()
				end,
				desc = "Restore Session",
			},
			{
				"<leader>wl",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore Last Session",
			},
			{
				"<leader>wd",
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
			copy_sync = {
				enable = false,
			},
			resize = {
				resize_step_x = 5,
				resize_step_y = 5,
			},
		},
	},
	{
		"diepm/vim-rest-console",
		config = function()
			vim.g.vrc_response_default_content_type = "application/json"
			vim.g.vrc_output_buffer_name = "__VRC_OUTPUT.json"
			vim.g.vrc_auto_format_response_patterns = {
				json = "jq",
			}
			vim.g.vrc_show_command = true
			vim.g.vrc_trigger = "<leader><CR>"
		end,
	},
	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		config = function()
			require("chatgpt").setup()
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"folke/trouble.nvim",
			"nvim-telescope/telescope.nvim",
		},
	},
	{
		"folke/zen-mode.nvim",
		opts = {
			window = {
				width = 120,
				height = 1,
			},
			plugins = {
				options = {
					enabled = true,
					ruler = false,
					showcmd = false,
					laststatus = 0,
				},
				tmux = { enabled = true },
				alacritty = {
					enabled = true,
				},
			},
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"3rd/image.nvim",
		opts = {}
	},
	{
		"vhyrro/luarocks.nvim",
		priority = 1000,
		config = true,
		opts = {
			rocks = { "magick" },
		}
	}
}
