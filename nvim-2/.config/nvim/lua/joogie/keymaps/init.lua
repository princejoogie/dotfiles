local keymap = vim.keymap.set

keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
keymap("n", "<C-n>", "<cmd>noh<CR>", { desc = "Clear search highlights" })
keymap("n", "<leader>ss", ":%s//", { desc = "Replace instances" })
keymap("n", "<leader>wk", "<cmd>WhichKey<CR>", { desc = "Which Key" })
keymap("n", "N", "Nzz", { desc = "Match previous" })
keymap("n", "n", "nzz", { desc = "Match next" })
keymap("x", "p", '"_dP', { desc = "Paste yanked text" })
keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- NEOTREE
keymap("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Toggle Filetree" })

-- FUGITIVE
keymap("n", "<leader>gf", ":diffget //2<CR>")
keymap("n", "<leader>gh", ":diffget //3<CR>")
keymap("n", "<leader>dv", ":Gvdiffsplit<CR>")
keymap("n", "<leader>dh", ":Ghdiffsplit<CR>")

-- TELESCOPE
pcall(function()
	local exts = require("telescope").extensions
	local builtin = require("telescope.builtin")

	keymap("n", "<C-f>", builtin.live_grep, { desc = "Live grep" })
	keymap("n", "<C-p>", builtin.find_files, { desc = "Find files" })
	keymap("n", "<leader>?", function()
		builtin.spell_suggest(require("telescope.themes").get_cursor({}))
	end, { desc = "Spell suggest" })
	keymap("n", "<leader>tr", "<cmd>Telescope resume<CR>", { desc = "Telescope resume" })
	keymap("n", "<leader>ch", builtin.command_history, { desc = "Command history" })
	keymap("n", "<leader>bf", builtin.buffers, { desc = "Buffers" })
	keymap("n", "<leader>fb", builtin.current_buffer_fuzzy_find, { desc = "Current buffer fuzzy find" })
	keymap("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
	keymap("n", "<leader>fw", builtin.grep_string, { desc = "Grep string" })
	keymap("n", "<leader>ts", builtin.treesitter, { desc = "Treesitter" })
	keymap("n", "<leader>sf", builtin.lsp_document_symbols, { desc = "Document symbols" })
	keymap("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
	keymap("n", "<leader>nh", exts.notify.notify, { desc = "Notify history" })
end)
