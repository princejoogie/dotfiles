local keymap = require("utils").keymap
local status, telescope = pcall(require, "telescope")
if (not status) then
  return
end

local M = {}

M.setup = function()
  telescope.setup(
    {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case"
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_stratey = "ascending",
        file_ignore_patterns = {"node_modules"},
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new
      }
    }
  )

  local extensions = {"gh", "dap", "notify"}

  pcall(
    function()
      for _, ext in ipairs(extensions) do
        telescope.load_extension(ext)
      end
    end
  )
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
