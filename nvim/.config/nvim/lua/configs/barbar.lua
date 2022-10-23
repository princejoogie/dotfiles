local barbar = safe_require("bufferline")

if not barbar then
	return
end

local M = {}

M.setup = function()
	barbar.setup({
		animation = true,
	})

	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = "*",
		callback = function()
			if vim.bo.filetype == "NvimTree" then
				local cwd = "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):upper()
				require("bufferline.api").set_offset(42, cwd)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWinLeave", {
		pattern = "*",
		callback = function()
			if vim.fn.expand("<afile>"):match("NvimTree") then
				require("bufferline.api").set_offset(0)
			end
		end,
	})
end

return M
