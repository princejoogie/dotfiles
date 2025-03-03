local cmd = require("joogie.utils").cmd

local keymap = vim.keymap.set

-- General Editing
keymap("i", "<C-h>", "<C-w>", { desc = "Delete word back" })
keymap("i", "<C-l>", "<Esc>ldwi", { desc = "Delete word front" })
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("n", "n", "nzz", { desc = "Match next" })
keymap("n", "N", "Nzz", { desc = "Match previous" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
keymap("x", "<leader>d", '"_d', { desc = "Delete without putting to register" })
keymap("n", "<leader>dm", function()
  vim.cmd("delmarks a-z")
  vim.cmd("delmarks A-Z")
end, { desc = "Delete all marks" })
keymap("x", "p", '"_dP', { desc = "Paste yanked text" })
keymap({ "i", "x", "n", "s" }, "<C-s>", cmd("w"), { desc = "Save file" })
keymap({ "n", "v" }, "$", "g_", { desc = "End of line" })
keymap("n", "<leader>ss", ":%s//", { desc = "Replace instances" })
vim.cmd([[
	nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
	nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
	vnoremap <expr> k v:count == 0 ? 'gk' : 'k'
	vnoremap <expr> j v:count == 0 ? 'gj' : 'j'
]])

-- Buffer and Tab Management
keymap("n", "<leader>q", cmd("q"), { desc = "Close buffer" })
keymap("n", "<leader>Q", cmd("qa!"), { desc = "Quit neovim without saving" })
keymap("n", "<leader>W", cmd("wqa"), { desc = "Quit neovim and save" })
keymap("n", "<C-w>z", cmd("tab split"), { desc = "Open buffer in new Tab" })
keymap("n", "<leader><Tab>", cmd("tabnext"), { desc = "Next Tab" })
keymap("n", "<leader><S-Tab>", cmd("tabprevious"), { desc = "Previous Tab" })

keymap("n", "<C-n>", cmd("noh"), { desc = "Clear search highlights" })
keymap("n", "<leader>cp", [[:let @+=expand('%:~:.')<CR>]], { desc = "Copy relative path" })

-- Quickfix
keymap("n", "<leader><S-Tab>", cmd("Cprev"), { desc = "Previous quickfix item" })
keymap("n", "<leader><Tab>", cmd("Cnext"), { desc = "Next quickfix item" })

-- Dadbob
keymap("n", "<leader>db", cmd("DBUIToggle"), { desc = "Toggle DBUI" })

-- Fugitive
keymap("n", "<leader>gg", cmd("Git"), { desc = "Open Git Fugitive" })
keymap("n", "<leader>gf", cmd("diffget //2"), { desc = "Diff get Current" })
keymap("n", "<leader>gh", cmd("diffget //3"), { desc = "Diff get Head" })
keymap("n", "<leader>dv", cmd("Gvdiffsplit"), { desc = "Diff Vertical" })
