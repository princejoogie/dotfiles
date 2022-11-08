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

-- use 'q' to quit from common plugins
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "qf", "help", "man", "lspinfo", "spectre_panel", "lir" },
	callback = function()
		vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]])
	end,
})

-- Set wrap and spell in markdown and gitcommit
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

return M
