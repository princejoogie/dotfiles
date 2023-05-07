return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"catppuccin/nvim",
		"nvim-tree/nvim-web-devicons",
		"famiu/bufdelete.nvim",
	},
	config = function()
		local C = require("catppuccin.palettes").get_palette("mocha")

		require("bufferline").setup({
			options = {
				offsets = {
					{
						filetype = "neo-tree",
						text = function()
							return vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):upper()
						end,
						padding = 0,
						text_align = "center",
						highlight = "NeoTreeTitle",
						separator = true,
					},
				},
				separator_style = "slant",
			},
			highlights = {
				fill = {
					fg = C.teal,
					bg = C.mantle,
				},
				separator_selected = {
					fg = C.mantle,
					bg = C.surface0,
				},
				separator_visible = {
					fg = C.mantle,
					bg = C.surface0,
				},
				separator = {
					fg = C.mantle,
					bg = C.surface0,
				},
				background = {
					fg = C.overlay0,
					bg = C.surface0,
				},
				tab = {
					fg = C.teal,
					bg = C.surface0,
				},
				tab_selected = {
					fg = C.teal,
					bg = C.surface0,
				},
				tab_close = {
					fg = C.teal,
					bg = C.surface0,
				},
				close_button = {
					fg = C.teal,
					bg = C.surface0,
				},
				close_button_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				close_button_selected = {
					fg = C.teal,
					bg = C.surface0,
				},
				buffer_visible = {
					fg = C.overlay0,
					bg = C.surface0,
				},
				buffer_selected = {
					fg = C.teal,
					bg = C.surface0,
					bold = true,
					italic = false,
				},
				numbers = {
					fg = C.teal,
					bg = C.surface0,
				},
				numbers_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				numbers_selected = {
					fg = C.teal,
					bg = C.surface0,
					bold = true,
					italic = false,
				},
				diagnostic = {
					fg = C.teal,
					bg = C.surface0,
				},
				diagnostic_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				diagnostic_selected = {
					fg = C.teal,
					bg = C.surface0,
					bold = true,
					italic = false,
				},
				hint = {
					fg = C.teal,
					sp = C.mantle,
					bg = C.surface0,
				},
				hint_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				hint_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				hint_diagnostic = {
					fg = C.teal,
					sp = C.mantle,
					bg = C.surface0,
				},
				hint_diagnostic_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				hint_diagnostic_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				info = {
					fg = C.teal,
					sp = C.mantle,
					bg = C.surface0,
				},
				info_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				info_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				info_diagnostic = {
					fg = C.teal,
					sp = C.mantle,
					bg = C.surface0,
				},
				info_diagnostic_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				info_diagnostic_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				warning = {
					fg = C.teal,
					sp = C.mantle,
					bg = C.surface0,
				},
				warning_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				warning_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				warning_diagnostic = {
					fg = C.teal,
					sp = C.mantle,
					bg = C.surface0,
				},
				warning_diagnostic_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				warning_diagnostic_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				error = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
				},
				error_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				error_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				error_diagnostic = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
				},
				error_diagnostic_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				error_diagnostic_selected = {
					fg = C.teal,
					bg = C.surface0,
					sp = C.mantle,
					bold = true,
					italic = false,
				},
				modified = {
					fg = C.teal,
					bg = C.surface0,
				},
				modified_visible = {
					fg = C.teal,
					bg = C.surface0,
				},
				modified_selected = {
					fg = C.teal,
					bg = C.surface0,
				},
				duplicate_selected = {
					fg = C.teal,
					bg = C.surface0,
					italic = false,
				},
				duplicate_visible = {
					fg = C.teal,
					bg = C.surface0,
					italic = false,
				},
				duplicate = {
					fg = C.teal,
					bg = C.surface0,
					italic = false,
				},
				indicator_selected = {
					fg = C.teal,
					bg = C.surface0,
				},
				pick_selected = {
					fg = C.teal,
					bg = C.surface0,
					bold = true,
					italic = false,
				},
				pick_visible = {
					fg = C.teal,
					bg = C.surface0,
					bold = true,
					italic = false,
				},
				pick = {
					fg = C.teal,
					bg = C.surface0,
					bold = true,
					italic = false,
				},
				offset_separator = {
					fg = C.surface1,
					bg = C.mantle,
				},
			},
		})
	end,
}
