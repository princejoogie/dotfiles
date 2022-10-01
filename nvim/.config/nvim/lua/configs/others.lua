local M = {}

M.toggleterm = function()
	local toggleterm = safe_require("toggleterm")
	if not toggleterm then
		return
	end

	toggleterm.setup({
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
		end,
		open_mapping = [[<C-\>]],
		hide_numbers = true,
		shade_filetypes = {},
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		direction = "horizontal",
		close_on_exit = true,
		shell = vim.o.shell,
	})

	function _G.set_terminal_keymaps()
		local opts = { noremap = true }
		vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
		vim.api.nvim_buf_set_keymap(0, "t", "jj", [[<C-\><C-n>]], opts)
		vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
		vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
		vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
		vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
	end

	vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
end

M.nvim_autopairs = function()
	local autopairs = safe_require("nvim-autopairs")
	if not autopairs then
		return
	end

	autopairs.setup({
		check_ts = true,
		ts_config = {
			lua = { "string", "source" },
			javascript = { "string", "template_string" },
			java = false,
		},
		disable_filetype = { "TelescopePrompt" },
	})

	local cmp_autopairs = safe_require("nvim-autopairs.completion.cmp")

	if not cmp_autopairs then
		return
	end

	local cmp = safe_require("cmp")

	if not cmp then
		return
	end

	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
end

M.nvim_tree = function()
	local nvim_tree = safe_require("nvim-tree")
	if not nvim_tree then
		return
	end

	nvim_tree.setup({
		view = {
			width = 40,
			hide_root_folder = true,
		},
		update_focused_file = {
			enable = true,
			update_cwd = false,
			ignore_list = {},
		},
		renderer = {
			highlight_opened_files = "current",
		},
	})
end

M.indent_blankline = function()
	local indent = safe_require("indent_blankline")
	if not indent then
		return
	end

	vim.opt.list = true

	indent.setup({
		space_char_blankline = " ",
		show_current_context = true,
		show_current_context_start = false,
	})
end

M.nvim_colorizer = function()
	local colorizer = safe_require("colorizer")
	if not colorizer then
		return
	end

	colorizer.setup({ "*" }, {
		RGB = true, -- #RGB hex codes
		RRGGBB = true, -- #RRGGBB hex codes
		names = false, -- "Name" codes like Blue
		RRGGBBAA = false, -- #RRGGBBAA hex codes
		rgb_fn = false, -- CSS rgb() and rgba() functions
		hsl_fn = false, -- CSS hsl() and hsla() functions
		css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
		css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
		mode = "background", -- Set the display mode.
	})
end

M.comment = function()
	local comment = safe_require("Comment")
	if not comment then
		return
	end

	comment.setup({
		toggler = {
			line = "<leader>cl",
			block = "<leader>bl",
		},
		opleader = {
			line = "<leader>cc",
			block = "<leader>cb",
		},
		pre_hook = function(ctx)
			local U = require("Comment.utils")

			local location = nil
			if ctx.ctype == U.ctype.block then
				location = require("ts_context_commentstring.utils").get_cursor_location()
			elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
				location = require("ts_context_commentstring.utils").get_visual_start_location()
			end

			return require("ts_context_commentstring.internal").calculate_commentstring({
				key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
				location = location,
			})
		end,
	})
end

M.package_info = function()
	local package = safe_require("package-info")
	if not package then
		return
	end

	package.setup({
		icons = {
			enable = true,
			style = {
				up_to_date = "|  ",
				outdated = "|  ",
			},
		},
		autostart = true,
		hide_up_to_date = true,
		hide_unstable_versions = false,
	})
end

M.nvim_ts_autotag = function()
	local autotag = safe_require("nvim-ts-autotag")
	if not autotag then
		return
	end

	autotag.setup()
end

M.ts_context = function()
	local ts_context = safe_require("treesitter-context")
	if not ts_context then
		return
	end

	ts_context.setup({ enable = true })
end

return M
