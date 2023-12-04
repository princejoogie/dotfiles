local previewers = require("telescope.previewers")
local builtin = require("telescope.builtin")

local delta = previewers.new_termopen_previewer({
	get_command = function(entry)
		if entry.status == "??" or "A " then
			return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value }
		end

		return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value .. "^!" }
	end,
})

local M = {}

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

return {
	"nvim-telescope/telescope.nvim",
	custom = M,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-github.nvim",
		"nvim-telescope/telescope-symbols.nvim",
	},
	config = function()
		local telescope = require("telescope")

		local ignored = {
			"node_modules",
			".git",
			".next",
			".turbo",
			".vercel",
			".expo",
			"dist",
			"build",
			"out",
			"yarn.lock",
			"package-lock.json",
			"pnpm-lock.yaml",
			"npm-debug.log",
			"yarn-debug.log",
			"yarn-error.log",
			".pnpm-debug.log",
			".tsbuildinfo",
		}

		local rg_globs = {}

		for _, pattern in ipairs(ignored) do
			table.insert(rg_globs, "--glob")
			table.insert(rg_globs, "!" .. pattern)
		end

		telescope.setup({
			defaults = {
				preview = {
					treesitter = false,
				},
				prompt_prefix = "   ",
				sorting_stratey = "ascending",
				vimgrep_arguments = {
					"rg",
					"-L",
					"-uu",
					"--hidden",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					---@diagnostic disable-next-line: deprecated
					unpack(rg_globs),
				},
			},
			pickers = {
				find_files = {
					find_command = {
						"rg",
						"-uu",
						"--files",
						"--hidden",
						---@diagnostic disable-next-line: deprecated
						unpack(rg_globs),
					},
				},
			},
		})

		local extensions = { "gh", "notify", "dir" }

		pcall(function()
			for _, ext in ipairs(extensions) do
				telescope.load_extension(ext)
			end
		end)
	end,
}
