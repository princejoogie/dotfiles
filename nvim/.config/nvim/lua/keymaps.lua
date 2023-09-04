---@diagnostic disable: different-requires
local keymap = vim.keymap.set

-- GENERAL KEYMAPS
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
keymap("n", "n", "nzz", { desc = "Match next" })
keymap("n", "N", "Nzz", { desc = "Match previous" })
keymap("x", "p", '"_dP', { desc = "Paste yanked text" })
keymap("n", "<M-j>", "<C-w>j", { desc = "Select window up" })
keymap("n", "<M-k>", "<C-w>k", { desc = "Select window down" })
keymap("n", "<M-l>", "<C-w>l", { desc = "Select window right" })
keymap("n", "<M-h>", "<C-w>h", { desc = "Select window left" })
keymap("n", "<M-J>", "<cmd>resize -5<CR>", { desc = "Decrease window height" })
keymap("n", "<M-K>", "<cmd>resize +5<CR>", { desc = "Increase window height" })
keymap("n", "<M-L>", "<cmd>vertical resize -5<CR>", { desc = "Decrease window width" })
keymap("n", "<M-H>", "<cmd>vertical resize +5<CR>", { desc = "Increase window width" })
keymap("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neotree" })
keymap("n", "<C-n>", "<cmd>noh<CR>", { desc = "Clear search highlights" })
keymap("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap("n", "<C-z>", "<Nop>", { desc = "Disable undo" })
keymap("n", "<leader>ls", "<cmd>Lazy sync<CR>")
keymap("n", "<leader>hn", "<cmd>TSNodeUnderCursor<CR>", { desc = "TS Node under cursor" })
keymap("n", "<leader>hg", "<cmd>TSHighlightCapturesUnderCursor<CR>", { desc = "TS Highlight captures under cursor" })
keymap("n", "<leader>mm", "<cmd>MarkdownPreview<CR>", { desc = "Markdown preview" })
keymap("n", "<leader>ss", ":%s//", { desc = "Replace instances" })
keymap("x", "<leader><Enter>", "<cmd>.!zsh<CR>", { desc = "Run zsh" })
keymap("n", "gG", "50%", { desc = "Go to middle of file" })
keymap("n", "gf", "<C-W>f", { desc = "Open file in new tab" })
keymap("v", "<M-j>", "<cmd>move '>+1<CR>gv-gv")
keymap("v", "<M-k>", "<cmd>move '<-2<CR>gv-gv")
keymap("v", "gf", "<C-W>f")
keymap("n", "<leader>wk", "<cmd>WhichKey<CR>", { desc = "Which Key" })
keymap("n", "<leader>aa", "<cmd>ZenMode<CR>", { desc = "Zen Mode" })
keymap("n", "<leader>oe", "<cmd>silent !wslview %<CR>", { desc = "Open Externally" })
keymap("n", "<leader>vi", "<cmd>ViewImage<CR>", { desc = "Open Externally" })
keymap("n", "<leader>bb", "<cmd>GitBlameToggle<CR>", { desc = "Toggle git blame" })
keymap("n", "<leader>nn", function()
	if vim.opt.relativenumber._value == true then
		vim.opt.relativenumber = false
	else
		vim.opt.relativenumber = true
	end
end, { desc = "Toggle relativenumber" })

-- Persistence
-- restore the session for the current directory
keymap("n", "<leader>rl", '<cmd>lua require("persistence").load()<CR>', {})

-- LSP
local diag = vim.diagnostic
keymap("n", "<leader>dj", diag.goto_next, { desc = "Next diagnostic" })
keymap("n", "<leader>dk", diag.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "<leader>e", diag.open_float, { desc = "Open float" })
keymap("n", "<leader>q", diag.setloclist, { desc = "Set loclist" })
keymap("n", "<leader>sy", "<cmd>SymbolsOutline<CR>", { desc = "Symbols outline" })
keymap("n", "<leader>ba", '<cmd>lua require("barbecue.ui").toggle()<CR>', { desc = "Toggle barbecue" })

-- SPECTRE
keymap("n", "<leader>S", '<cmd>lua require("spectre").open()<CR>', {
	desc = "Open Spectre",
})
keymap("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
	desc = "Search current word",
})
keymap("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
	desc = "Search current word",
})
keymap("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
	desc = "Search on current file",
})

-- FUGITIVE
keymap("n", "<leader>gf", ":diffget //2<CR>")
keymap("n", "<leader>gh", ":diffget //3<CR>")
keymap("n", "<leader>dv", ":Gvdiffsplit<CR>")
keymap("n", "<leader>dh", ":Ghdiffsplit<CR>")

-- TELESCOPE
pcall(function()
	local exts = require("telescope").extensions
	local builtin = require("telescope.builtin")
	local custom = require("plugins.telescope").custom

	keymap("n", "<C-f>", builtin.live_grep, { desc = "Live grep" })
	keymap("n", "<C-p>", builtin.find_files, { desc = "Find files" })
	keymap("n", "<leader>?", function()
		builtin.spell_suggest(require("telescope.themes").get_cursor({}))
	end, { desc = "Spell suggest" })
	keymap("n", "<leader>ch", builtin.command_history, { desc = "Command history" })
	keymap("n", "<leader>bf", builtin.buffers, { desc = "Buffers" })
	keymap("n", "<leader>fb", builtin.current_buffer_fuzzy_find, { desc = "Current buffer fuzzy find" })
	keymap("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
	keymap("n", "<leader>fw", builtin.grep_string, { desc = "Grep string" })
	keymap("n", "<leader>ts", builtin.treesitter, { desc = "Treesitter" })
	keymap("n", "<leader>sf", builtin.lsp_document_symbols, { desc = "Document symbols" })
	keymap("n", "<leader>gs", custom.git_status, { desc = "Git status" })
	keymap("n", "<leader>gc", custom.git_commits, { desc = "Git commits" })
	keymap("n", "<leader>gb", custom.git_bcommits, { desc = "Git bcommits" })
	keymap("n", "<leader>gi", custom.gh_issues, { desc = "Github issues" })
	keymap("n", "<leader>gp", custom.gh_prs, { desc = "Github prs" })
	keymap("n", "<leader>nh", exts.notify.notify, { desc = "Notify history" })
end)

keymap("n", "<leader>fd", "<cmd>GrepInDirectory<CR>", { desc = "Grep in directory" })
keymap("n", "<leader>pd", "<cmd>FileInDirectory<CR>", { desc = "File in directory" })

keymap("n", "<leader><S-TAB>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
keymap("n", "<leader><TAB>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>0", "<cmd>BufferLinePick<CR>", { desc = "Pick a buffer" })
keymap("n", "<leader>bd", "<cmd>%bd|e#|bd#<CR>", { desc = "Close all buffers" })
keymap("n", "<leader>bc", function()
	require("bufdelete").bufdelete(vim.api.nvim_get_current_buf(), true)
end, { desc = "Close current buffer" })

-- HARPOON
pcall(function()
	local harpoon_ui = require("harpoon.ui")
	local harpoon_mark = require("harpoon.mark")
	keymap("n", "<leader>ha", harpoon_mark.add_file, { desc = "Add file" })
	keymap("n", "<leader>hh", harpoon_ui.toggle_quick_menu, { desc = "Toggle harpoon" })
end)

-- PACKAGE-INFO
pcall(function()
	local pi_base = require("package-info")
	keymap("n", "<leader>nc", pi_base.hide, { desc = "Hide package info" })
	keymap("n", "<leader>nd", pi_base.delete, { desc = "Delete package" })
	keymap("n", "<leader>ni", pi_base.install, { desc = "Install package" })
	keymap("n", "<leader>np", pi_base.change_version, { desc = "Change package version" })
	keymap("n", "<leader>nr", pi_base.reinstall, { desc = "Reinstall package" })
	keymap("n", "<leader>ns", pi_base.show, { desc = "Show package info" })
	keymap("n", "<leader>nu", pi_base.update, { desc = "Update package" })
end)

-- RENAME FILE
pcall(function()
	local jsExtensions = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	}

	local RenameBuffer = function()
		if not vim.tbl_contains(jsExtensions, vim.bo.filetype) then
			vim.ui.input({
				prompt = "New path:",
				default = vim.api.nvim_buf_get_name(0),
			}, function(input)
				vim.lsp.util.rename(vim.api.nvim_buf_get_name(0), input, {})
			end)
		else
			vim.cmd("TypescriptRenameFile")
		end
	end

	keymap("n", "<leader>rf", RenameBuffer, { desc = "JS Rename file" })
end)
