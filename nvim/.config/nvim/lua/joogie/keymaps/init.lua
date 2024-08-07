local keymap = vim.keymap.set

keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
keymap("n", "<C-n>", "<cmd>noh<CR>", { desc = "Clear search highlights" })
keymap("n", "<leader>q", "<cmd>:q<CR>", { desc = "Close buffer" })
keymap("n", "<leader>ss", ":%s//", { desc = "Replace instances" })
keymap("n", "<leader>wk", "<cmd>WhichKey<CR>", { desc = "Which Key" })
keymap("n", "N", "Nzz", { desc = "Match previous" })
keymap("n", "n", "nzz", { desc = "Match next" })
keymap("x", "p", '"_dP', { desc = "Paste yanked text" })
keymap("x", "<leader>d", '"_d', { desc = "Delete without putting to register" })
keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap({ "n", "v" }, "$", "g_", { desc = "End of line" })
keymap("n", "<leader>cp", [[:let @+=expand('%:~:.')<CR>]], { desc = "Copy relative path" })
keymap("n", "<leader><Tab>", "<cmd>Cnext<CR>", { desc = "Next quickfix item" })
keymap("n", "<leader><S-Tab>", "<cmd>Cprev<CR>", { desc = "Previos quickfix item" })
keymap("i", "<C-h>", "<C-w>", { desc = "Delete word back" })
keymap("i", "<C-l>", "<Esc>ldwi", { desc = "Delete word front" })

-- resize
keymap("n", "<C-Left>", [[<cmd>lua require("tmux").resize_left()<cr>]], { desc = "+ Resize Vertically" })
keymap("n", "<C-Down>", [[<cmd>lua require("tmux").resize_bottom()<cr>]], { desc = "+ Resize Horizontally" })
keymap("n", "<C-Up>", [[<cmd>lua require("tmux").resize_top()<cr>]], { desc = "- Resize Horizontally" })
keymap("n", "<C-Right>", [[<cmd>lua require("tmux").resize_right()<cr>]], { desc = "- Resize Vertically" })

-- pane-switch
keymap("n", "<C-h>", [[<cmd>lua require("tmux").move_left()<cr>]])
keymap("n", "<C-j>", [[<cmd>lua require("tmux").move_bottom()<cr>]])
keymap("n", "<C-k>", [[<cmd>lua require("tmux").move_top()<cr>]])
keymap("n", "<C-l>", [[<cmd>lua require("tmux").move_right()<cr>]])

vim.cmd([[
	nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
	nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
	vnoremap <expr> k v:count == 0 ? 'gk' : 'k'
	vnoremap <expr> j v:count == 0 ? 'gj' : 'j'
]])

-- TYPESCRIPT-TOOLS
keymap("n", "<leader>rf", "<cmd>TSToolsRenameFile<CR>", { desc = "TS Rename File" })

-- SPECTRE
pcall(function()
	local spectre = require("spectre")
	keymap("n", "<leader>S", spectre.toggle, { desc = "Toggle Spectre" })
	keymap("v", "<leader>sw", spectre.open_visual, { desc = "Search current word" })
	keymap("n", "<leader>sw", function()
		spectre.open_visual({ select_word = true })
	end, { desc = "Search current word" })
	keymap("n", "<leader>sp", function()
		spectre.open_file_search({ select_word = true })
	end, { desc = "Search on current file" })
end)

-- NEOTREE
keymap("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Toggle Filetree" })
keymap("n", "<leader>cm", "<cmd>ZenMode<CR>", { desc = "Toggle ZenMode" })
keymap("n", "<leader>ai", "<cmd>ChatGPT<CR>", { desc = "Toggle ChatGPT" })
keymap(
	{ "n", "v", "x" },
	"<leader>ae",
	"<cmd>ChatGPTEditWithInstructions<CR>",
	{ desc = "Toggle ChatGPTEditWithInstructions" }
)
keymap({ "n", "v", "x" }, "<leader>ar", ":ChatGPTRun", { desc = "ChatGPTRun x" })
keymap("n", "<leader>mm", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle MarkdownPreview" })

-- NEOTEST
pcall(function()
	local neotest = require("neotest")
	keymap("n", "<leader>,s", neotest.summary.toggle, { desc = "[Test] Toggle summary" })
	keymap("n", "<leader>,e", neotest.output.open, { desc = "[Test] Output open" })
	keymap("n", "<leader>,r", neotest.run.run, { desc = "[Test] Run nearest" })
	keymap("n", "<leader>,w", function()
		neotest.watch.toggle(vim.fn.expand("%"))
	end, { desc = "[Test] Watch file" })
	keymap("n", "<leader>,f", function()
		neotest.run.run(vim.fn.expand("%"))
	end, { desc = "[Test] Run file" })
end)

-- HARPOON
pcall(function()
	local harpoon_ui = require("harpoon.ui")
	local harpoon_mark = require("harpoon.mark")
	keymap("n", "<leader>ha", harpoon_mark.add_file, { desc = "Add file" })
	keymap("n", "<leader>hh", harpoon_ui.toggle_quick_menu, { desc = "Toggle harpoon" })
end)

-- PACKAGE-INFO
pcall(function()
	local fidget = require("fidget")
	local pi_base = require("package-info")

	keymap("n", "<leader>nc", pi_base.hide, { desc = "Hide package info" })
	keymap("n", "<leader>np", pi_base.change_version, { desc = "Change package version" })
	keymap("n", "<leader>ns", function()
		pi_base.show({ force = true })
		fidget.notify(pi_base.get_status(), vim.log.levels.INFO, { annote = "", key = "foobar" })
	end, { desc = "Show package info" })
	keymap("n", "<leader>nu", pi_base.update, { desc = "Update package" })
end)

-- FUGITIVE
keymap("n", "<leader>gg", ":Git<CR>", { desc = "Open Git Fugitive" })
keymap("n", "<leader>gf", ":diffget //2<CR>", { desc = "Diff get Current" })
keymap("n", "<leader>gh", ":diffget //3<CR>", { desc = "Diff get Head" })
keymap("n", "<leader>dv", ":Gvdiffsplit<CR>", { desc = "Diff Vertical" })
keymap("n", "<leader>dh", ":Ghdiffsplit<CR>", { desc = "Diff Horizontal" })
keymap("n", "<leader>di", ":DiffviewOpen<CR>", { desc = "Diff View Open" })
keymap("n", "<leader>dh", ":DiffviewFileHistory<CR>", { desc = "Diff View File History" })
keymap("n", "<leader>dq", ":tabc<CR>", { desc = "Close Tab" })
keymap("n", "<C-w>z", ":tab split<CR>", { desc = "Open buffer in new Tab" })

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
	keymap("n", "<leader>fd", "<cmd>GrepInDirectory<CR>", { desc = "Grep in directory" })
	keymap("n", "<leader>P", "<cmd>FileInDirectory<CR>", { desc = "File in directory" })
end)
