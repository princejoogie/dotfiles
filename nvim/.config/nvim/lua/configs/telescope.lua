local keymap = require("utils").keymap
local status, telescope = pcall(require, "telescope")
if (not status) then
  return
end

local M = {}

pcall(require("telescope").load_extension, "gh")
pcall(require("telescope").load_extension, "dap")
pcall(require("telescope").load_extension, "notify")

M.setup = function()
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

keymap("n", "<leader>gi", M.gh_issues)
keymap("n", "<leader>gp", M.gh_prs)

return M
