local M = {}

---@diagnostic disable-next-line: duplicate-set-field
_G.safe_require = function(module_name)
	local package_exists, module = pcall(require, module_name)
	if not package_exists then
		vim.defer_fn(function()
			vim.schedule(function()
				vim.notify("Could not load module: " .. module_name, vim.log.levels.ERROR)
			end)
		end, 1000)
		return nil
	else
		return module
	end
end

M.keymap = function(mode, lhs, rhs, opts)
	local def_opts = { noremap = true, silent = true }
	if opts == nil then
		opts = {}
	end

	local keyopts = vim.tbl_extend("force", def_opts, opts)

	if lhs == nil then
		lhs = ""
	end

	if rhs == nil then
		rhs = ""
	end

	vim.keymap.set(mode, lhs, rhs, keyopts)
end

M.buf_keymap = function(bufnr, mode, lhs, rhs, opts)
	local def_opts = { noremap = true, silent = true }
	if opts == nil then
		opts = {}
	end

	local keyopts = vim.tbl_extend("force", def_opts, opts)

	if lhs == nil then
		lhs = ""
	end

	if rhs == nil then
		rhs = ""
	end
	vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, keyopts)
end

M.buf_option = function(bufnr, lhs, rhs)
	if lhs == nil then
		lhs = ""
	end

	if rhs == nil then
		rhs = ""
	end
	vim.api.nvim_buf_set_option(bufnr, lhs, rhs)
end

M.bmap = function(bufnr, mode, lhs, rhs, opts)
	local def_opts = { noremap = true, silent = true }
	if opts == nil then
		opts = {}
	end

	local keyopts = vim.tbl_extend("force", def_opts, opts)
	vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, keyopts)
end

M.bopts = function(bufnr, lhs, rhs)
	vim.api.nvim_buf_set_option(bufnr, lhs, rhs)
end

M.icons = {
	Error = " ",
	Warn = " ",
	Hint = " ",
	Info = " ",
	Spinner = {
		"⣾",
		"⣷",
		"⣯",
		"⣟",
		"⡿",
		"⢿",
		"⣻",
		"⣽",
	},
}

return M
