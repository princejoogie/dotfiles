local telescope = safe_require("telescope")

if not telescope then
	return
end

local previewers = require("telescope.previewers")
local builtin = require("telescope.builtin")

local M = {}

M.setup = function()
	telescope.setup({
		defaults = {
			prompt_prefix = "   ",
			sorting_stratey = "ascending",
			file_ignore_patterns = {
				"node_modules/",
				".git/",
				"dist/",
				"build/",
				"yarn.lock",
				"package-lock.json",
			},
			vimgrep_arguments = {
				"rg",
				"--hidden",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
			},
		},
		pickers = {
			find_files = {
				find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
			},
		},
	})

	local extensions = { "gh", "dap", "notify", "dir" }

	pcall(function()
		for _, ext in ipairs(extensions) do
			telescope.load_extension(ext)
		end
	end)
end

local delta = previewers.new_termopen_previewer({
	get_command = function(entry)
		if entry.status == "??" or "A " then
			return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value }
		end

		return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value .. "^!" }
	end,
})

function M.gh_issues()
	local opts = {}
	opts.prompt_title = " Issues"
	require("telescope").extensions.gh.issues(opts)
end

function M.gh_prs()
	local opts = {}
	opts.prompt_title = " Pull Requests"
	require("telescope").extensions.gh.pull_request(opts)
end

function M.git_status()
	local opts = {}
	opts.prompt_title = " Git Status"
	opts.previewer = delta
	builtin.git_status(opts)
end

function M.git_commits()
	local opts = {}
	opts.prompt_title = " Git Commits"
	opts.previewer = delta
	builtin.git_commits(opts)
end

function M.git_bcommits()
	local opts = {}
	opts.prompt_title = " Git Commits"
	opts.previewer = delta
	builtin.git_bcommits(opts)
end

return M
