return {
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
		keys = {
			-- Resize
			{
				"<C-Left>",
				function()
					require("tmux").resize_left()
				end,
			},
			{
				"<C-Down>",
				function()
					require("tmux").resize_bottom()
				end,
			},
			{
				"<C-Up>",
				function()
					require("tmux").resize_top()
				end,
			},
			{
				"<C-Right>",
				function()
					require("tmux").resize_right()
				end,
			},

			-- Movement
			{
				"<C-h",
				function()
					require("tmux").move_left()
				end,
			},
			{
				"<C-j>",
				function()
					require("tmux").move_bottom()
				end,
			},
			{
				"<C-k>",
				function()
					require("tmux").move_top()
				end,
			},
			{
				"<C-l>",
				function()
					require("tmux").move_right()
				end,
			},
		},
	},
}
