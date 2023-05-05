return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"catppuccin/nvim",
		"nvim-tree/nvim-web-devicons",
		"famiu/bufdelete.nvim",
	},
	config = function()
		local mocha = require("catppuccin.palettes").get_palette("mocha")
		require("bufferline").setup({
			options = {
				offsets = {
					{
						filetype = "neo-tree",
						text = function()
							return vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):upper()
						end,
						padding = 1,
						text_align = "center",
						highlight = "Directory",
					},
				},
			},
			highlights = require("catppuccin.groups.integrations.bufferline").get({
				styles = { "italic", "bold" },
				custom = {
					all = {
						fill = { bg = "#000000" },
					},
					mocha = {
						background = { fg = mocha.text },
					},
					latte = {
						background = { fg = "#000000" },
					},
				},
			}),
			seperator_style = "slope",
		})
	end,
}
