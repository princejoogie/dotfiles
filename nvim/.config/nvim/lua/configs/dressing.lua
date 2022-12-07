local dressing = safe_require("dressing")
if not dressing then
	return
end

local M = {}

M.setup = function()
	dressing.setup({
		input = {
			enabled = true,
			default_prompt = "➤ ",
			prompt_align = "left",
			insert_only = true,
			anchor = "SW",
			border = "rounded",
			relative = "cursor",
			prefer_width = 40,
			width = nil,
			max_width = { 140, 0.9 },
			min_width = { 20, 0.2 },
			win_options = {
				winblend = 0,
				winhighlight = "",
			},
			override = function(conf)
				return conf
			end,
			get_config = nil,
		},
		select = {
			enabled = true,
			backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
			telescope = nil,
			fzf = {
				window = {
					width = 0.5,
					height = 0.4,
				},
			},
			fzf_lua = {
				winopts = {
					width = 0.5,
					height = 0.4,
				},
			},
			nui = {
				position = "50%",
				size = nil,
				relative = "editor",
				border = {
					style = "rounded",
				},
				max_width = 80,
				max_height = 40,
			},
			builtin = {
				anchor = "NW",
				border = "rounded",
				relative = "editor",
				width = nil,
				max_width = { 140, 0.8 },
				min_width = { 40, 0.2 },
				height = nil,
				max_height = 0.9,
				min_height = { 10, 0.2 },
				win_options = {
					winblend = 10,
					winhighlight = "",
				},
				override = function(conf)
					return conf
				end,
			},
			format_item_override = {},
			get_config = nil,
		},
	})
end

return M
