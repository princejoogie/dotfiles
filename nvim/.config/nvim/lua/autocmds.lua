local M = {}

M.RemoveQFItem = function()
	local curqfidx = vim.fn.line(".")
	local qfall = vim.fn.getqflist()
	table.remove(qfall, curqfidx)
	vim.fn.setqflist(qfall, "r")
	vim.cmd(curqfidx .. "cfirst")
	vim.cmd(":copen")
end

vim.api.nvim_create_user_command("RemoveQFItem", M.RemoveQFItem, {
	desc = "Delete item with dd when in quickfix list",
})

vim.cmd("autocmd FileType qf map <buffer> dd :RemoveQFItem<CR>")

return M
