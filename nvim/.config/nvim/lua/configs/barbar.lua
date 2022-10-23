local barbar = safe_require("bufferline")

if not barbar then
	return
end

local M = {}

M.setup = function()
	barbar.setup({
		animation = true,
	})

	local tree = safe_require("nvim-tree")

	if tree then
		local Event = require("nvim-tree.api").events.Event
		local tree_view = require("nvim-tree.view")
		local tree_api = require("nvim-tree.api")
		local barbar_api = require("bufferline.api")

		local function get_tree_size()
			return tree_view.View.width
		end

		local function get_folder_name()
			return "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):upper()
		end

		tree_api.events.subscribe(Event.TreeOpen, function()
			barbar_api.set_offset(get_tree_size() + 2, get_folder_name())
		end)

		tree_api.events.subscribe(Event.Resize, function()
			barbar_api.set_offset(get_tree_size() + 2, get_folder_name())
		end)

		tree_api.events.subscribe(Event.TreeClose, function()
			barbar_api.set_offset(0)
		end)
	end
end

return M
