local telescope = require("telescope")

local M = {}

telescope.load_extension("gh")
telescope.load_extension("dap")
telescope.load_extension("notify")

telescope.setup {
  defaults = {
    sorting_stratey = "ascending"
  },
  pickers = {
    find_files = {
      hidden = true
    }
  },
  extensions = {}
}

-- requires GitHub extension
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
-- end github functions

return M
