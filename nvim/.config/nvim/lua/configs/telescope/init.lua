local telescope = safe_require("telescope")
if not telescope then
	return
end

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
		},
	})

	local extensions = { "gh", "dap", "notify" }

	pcall(function()
		for _, ext in ipairs(extensions) do
			telescope.load_extension(ext)
		end
	end)
end

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

safe_require("configs.telescope.grep-dirs")

return M
