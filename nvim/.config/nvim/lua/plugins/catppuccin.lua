return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		local catppuccin = require("catppuccin")
		local flavour = "mocha"

		catppuccin.setup({
			flavour = flavour,
			term_colors = false,
			no_italic = true,
			no_bold = true,
			transparent_background = true,
			color_overrides = {
				mocha = {
					crust = "#1E1E2E",
					mantle = "#181825",
					--[[ base = "#11111B", ]]
					base = "#000000",
				},
			},
			highlight_overrides = {
				mocha = function(C)
					return {
						TabLineSel = { bg = C.pink },
						CmpBorder = { fg = C.surface2 },
						Pmenu = { bg = C.none },
						TelescopeBorder = { link = "FloatBorder" },
						CursorLine = { bg = "#181825" },
						GitBlame = { bg = "#181825", fg = C.surface2 },
					}
				end,
			},
			background = { -- :h background
				light = "latte",
				dark = flavour,
			},
			show_end_of_buffer = false, -- show the '~' characters after the end of buffers
			dim_inactive = {
				enabled = false,
				shade = "dark",
				percentage = 0.15,
			},
			styles = {
				comments = {},
				conditionals = {},
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
			},
			custom_highlights = {},
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				notify = false,
				mini = false,
				-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
			},
		})

		vim.cmd.colorscheme("catppuccin")
		vim.opt.background = "dark"
	end,
}
