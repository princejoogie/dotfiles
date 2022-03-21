local opts = {noremap = true}
local ui = '<cmd>lua require("harpoon.ui").'
local mark = '<cmd>lua require("harpoon.mark").'

vim.api.nvim_set_keymap("n", "<leader>hh", ui .. "toggle_quick_menu()<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>hn", ui .. "nav_next()<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>hp", ui .. "nav_prev()<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>ha", mark .. "add_file()<CR>", opts)
