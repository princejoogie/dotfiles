local cmd = require("joogie.utils").cmd
local Util = require("joogie.utils")

local keymap = vim.keymap.set

-- General Editing
keymap("n", "<M-a>", "ggVG", { desc = "Select all" })
keymap("i", "<C-h>", "<C-w>", { desc = "Delete word back" })
keymap("i", "<C-l>", "<Esc>ldwi", { desc = "Delete word front" })
keymap({ "n", "v" }, "$", "g$", { desc = "Move to end of visual line" })
keymap({ "n", "v" }, "0", "g0", { desc = "Move to start of visual line" })
keymap("n", "Q", "@q", { desc = "Repeat macro from q register" })
keymap({ "t", "i" }, "jj", "<Esc>", { desc = "Exit insert mode" })
keymap({ "t", "i" }, "JJ", "<C-\\><C-n>", { desc = "Exit insert mode" })
keymap({ "i", "v" }, "<Esc>", "<Esc>", { desc = "Esc" })
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

keymap("n", "]q", cmd("Cnext"), { desc = "Next quickfix" })
keymap("n", "[q", cmd("Cprev"), { desc = "Previous quickfix" })

keymap("n", "<C-n>", cmd("noh"), { desc = "Clear search highlights" })
keymap("n", "<leader>cp", [[:let @+=expand('%:~:.')<CR>]], { desc = "Copy relative path" })

-- Dadbob
keymap("n", "<leader>db", cmd("DBUIToggle"), { desc = "Toggle DBUI" })

-- Fugitive
keymap("n", "<leader>Ga", cmd("Git add ."), { desc = "Fugitive: add all" })
keymap("n", "<leader>Gc", cmd("Git commit"), { desc = "Fugitive: commit" })
keymap("n", "<leader>Gp", cmd("Git push"), { desc = "Fugitive: push" })
keymap("n", "<leader>GP", cmd("Git push --force-with-lease"), { desc = "Fugitive: push force" })
keymap("n", "<leader>G!", function()
  Util.exec({ "git add .", "git commit -m 'commit'", "git push" })
end, { desc = "Fugitive: push yolo" })
keymap("n", "<leader>gf", cmd("diffget //2"), { desc = "Diff get Current" })
keymap("n", "<leader>gh", cmd("diffget //3"), { desc = "Diff get Head" })
keymap("n", "<leader>dv", cmd("Gvdiffsplit"), { desc = "Diff Vertical" })
keymap("n", "<leader>co", cmd("!git co"), { desc = "Git Checkout" })
