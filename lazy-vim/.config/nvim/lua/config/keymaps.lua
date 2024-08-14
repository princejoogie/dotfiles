-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set

keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
keymap("n", "<C-n>", "<cmd>noh<CR>", { desc = "Clear search highlights" })
keymap("n", "<leader>cp", [[:let @+=expand('%:~:.')<CR>]], { desc = "Copy relative path" })
keymap("n", "<leader><Tab>", "<cmd>Cnext<CR>", { desc = "Next quickfix item" })
keymap("n", "<leader><S-Tab>", "<cmd>Cprev<CR>", { desc = "Previos quickfix item" })
