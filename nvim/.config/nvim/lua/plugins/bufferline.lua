return {
	"akinsho/bufferline.nvim",
	dependencies = { "catppuccin/nvim" },
	config = function()
		local bufferline = require("bufferline")
		local mocha = require("catppuccin.palettes").get_palette("mocha")

		bufferline.setup({
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
				buffer_close_icon = "",
				modified_icon = "●",
				close_icon = "",
				max_name_length = 18,
				max_prefix_length = 15,
				truncate_names = true,
				tab_size = 18,
				diagnostics = "nvim_lsp",
				separator_style = "thin", -- { "", "" },
				numbers = "none",
				right_mouse_command = "vert sbuffer %d", -- can be a string | function, see "Mouse actions"
				left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
				middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
				left_trunc_marker = "",
				right_trunc_marker = "",
				diagnostics_update_in_insert = false,
				diagnostics_indicator = function(count)
					if count > 9 then
						return "9+"
					end
					return tostring(count)
				end,
				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				show_duplicate_prefix = true,
				enforce_regular_tabs = false,
				persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
				always_show_bufferline = true,
				sort_by = "insert_after_current",
				hover = {
					enabled = true,
					delay = 0,
					reveal = { "close" },
				},
				close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
			},
		})
	end,
}
