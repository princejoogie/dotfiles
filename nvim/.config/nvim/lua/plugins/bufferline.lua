return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"catppuccin/nvim",
		"nvim-tree/nvim-web-devicons",
		"famiu/bufdelete.nvim",
	},
	config = function()
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
				separator_style = "thin",
			},
			highlights = {
				tab = { bg = "NONE" },
				tab_selected = { bg = "NONE" },
				tab_close = { bg = "NONE" },
				separator_selected = { bg = "NONE" },
				separator_visible = { bg = "NONE" },
				separator = { bg = "NONE" },
				indicator_selected = { bg = "NONE" },
			},
		})
	end,
}
