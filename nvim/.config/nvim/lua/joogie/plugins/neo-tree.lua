local cmd = require("joogie.utils").cmd

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		{ "s1n7ax/nvim-window-picker", opts = {} },
	},
	opts = function(_, opts)
		local function on_move(data)
			print("on_move", vim.inspect(data))
			Snacks.rename.on_rename_file(data.source, data.destination)
		end
		local events = require("neo-tree.events")
		opts.event_handlers = opts.event_handlers or {}
		vim.list_extend(opts.event_handlers, {
			{ event = events.FILE_MOVED, handler = on_move },
			{ event = events.FILE_RENAMED, handler = on_move },
		})
	end,
	config = function(custom_opts)
		local opts = vim.tbl_deep_extend("force", custom_opts, {
			window = {
				mappings = {
					["<C-b>"] = "noop",
					["/"] = "noop",
				},
			},
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
				filtered_items = {
					hide_dotfiles = false,
				},
				hijack_netrw_behavior = "open_default",
			},
		})

		require("neo-tree").setup(opts)
	end,
	keys = {
		{ "<C-b>", cmd("Neotree toggle"), desc = "Toggle Filetree" },
	},
}
