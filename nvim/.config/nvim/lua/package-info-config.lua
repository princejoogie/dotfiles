local package = require("package-info")

package.setup(
  {
    colors = {
      up_to_date = "#637777",
      outdated = "#637777"
    },
    icons = {
      enable = true,
      style = {
        up_to_date = "=> ",
        outdated = "=> "
      }
    },
    hide_up_to_date = true,
    hide_unstable_versions = false
  }
)

local opts = {silent = true, noremap = true}

-- Show package versions
vim.api.nvim_set_keymap("n", "<leader>ns", ":lua require('package-info').show()<CR>", opts)
-- Hide package versions
vim.api.nvim_set_keymap("n", "<leader>nc", ":lua require('package-info').hide()<CR>", opts)
-- Update package on line
vim.api.nvim_set_keymap("n", "<leader>nu", ":lua require('package-info').update()<CR>", opts)
-- Delete package on line
vim.api.nvim_set_keymap("n", "<leader>nd", ":lua require('package-info').delete()<CR>", opts)
-- Install a new package
vim.api.nvim_set_keymap("n", "<leader>ni", ":lua require('package-info').install()<CR>", opts)
-- Reinstall dependencies
vim.api.nvim_set_keymap("n", "<leader>nr", ":lua require('package-info').reinstall()<CR>", opts)
-- Install a different package version
vim.api.nvim_set_keymap("n", "<leader>np", ":lua require('package-info').change_version()<CR>", opts)
