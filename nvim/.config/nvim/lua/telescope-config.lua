local telescope = require('telescope')

local M = {}

telescope.load_extension('gh')
telescope.load_extension('dap')

telescope.setup {
	defaults = {
		sorting_stratey = 'ascending',
	},
	pickers = {
		find_files = {
			hidden = true,
		},
	},
	extensions = {}
}

local gopts = { noremap = true }
local builtin = '<cmd>lua require("telescope.builtin").'

vim.api.nvim_set_keymap('n', '<C-p>', builtin..'find_files()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<C-f>', builtin..'live_grep()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<leader>fw', builtin..'grep_string()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<leader>fb', builtin..'current_buffer_fuzzy_find()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<leader>fh', builtin..'help_tags()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<leader>gs', builtin..'git_status()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<leader>ts', builtin..'treesitter()<CR>', gopts)
-- vim.api.nvim_set_keymap('n', '<leader>q', builtin..'diagnostics()<CR>', gopts)

vim.api.nvim_set_keymap('n', '<leader>gi', '<cmd>lua require("telescope-config").gh_issues()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<leader>gp', '<cmd>lua require("telescope-config").gh_prs()<CR>', gopts)
vim.api.nvim_set_keymap('n', '<leader>gi', '<cmd>lua require("telescope-config").gh_issues()<CR>', gopts)

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
