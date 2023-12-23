local M = {}

M.find_git_root = function()
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()

	if current_file == "" then
		current_dir = cwd
	else
		current_dir = vim.fn.fnamemodify(current_file, ":h")
	end

	local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		print("Not a git repository. Searching on current working directory")
		return cwd
	end
	return git_root
end

M.icons = {
	Error = " ",
	Warn = " ",
	Info = " ",
	Hint = " ",
}

M.live_grep_git_root = function()
	local git_root = M.find_git_root()
	if git_root then
		require("telescope.builtin").live_grep({
			search_dirs = { git_root },
		})
	end
end

M.telescope_live_grep_open_files = function()
	require("telescope.builtin").live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end

return M
