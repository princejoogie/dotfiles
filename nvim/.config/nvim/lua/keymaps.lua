---@diagnostic disable: different-requires
local keymap = vim.keymap.set

-- GENERAL KEYMAPS
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
keymap("n", "n", "nzz", { desc = "Match next" })
keymap("n", "N", "Nzz", { desc = "Match previous" })
keymap("n", "<M-j>", "<C-w>j", { desc = "Select window up" })
keymap("n", "<M-k>", "<C-w>k", { desc = "Select window down" })
keymap("n", "<M-l>", "<C-w>l", { desc = "Select window right" })
keymap("n", "<M-h>", "<C-w>h", { desc = "Select window left" })
keymap("n", "<M-J>", ":resize -5<CR>", { desc = "Decrease window height" })
keymap("n", "<M-K>", ":resize +5<CR>", { desc = "Increase window height" })
keymap("n", "<M-L>", ":vertical resize -5<CR>", { desc = "Decrease window width" })
keymap("n", "<M-H>", ":vertical resize +5<CR>", { desc = "Increase window width" })
keymap("n", "<C-b>", ":Neotree toggle<CR>", { desc = "Toggle Neotree" })
keymap("n", "<C-n>", ":noh<CR>", { desc = "Clear search highlights" })
keymap("n", "<C-s>", ":w<CR>", { desc = "Save file" })
keymap("n", "<C-z>", "<Nop>", { desc = "Disable undo" })
keymap("n", "<leader>hg", ":TSHighlightCapturesUnderCursor<CR>")
keymap("n", "<leader>mm", ":MarkdownPreview<CR>", { desc = "Markdown preview" })
keymap("n", "<leader>d", '"_d')
keymap("v", "<leader>d", '"_d')
keymap("v", "<C-p>", '"_dP')
keymap("n", "<leader>qn", ":cn<CR>", { desc = "Next quickfix" })
keymap("n", "<leader>qp", ":cp<CR>", { desc = "Previous quickfix" })
keymap("n", "<leader>qf", ":copen<CR>", { desc = "Open quickfix" })
keymap("n", "<leader><Enter>", ":.!zsh<CR>", { desc = "Run zsh" })
keymap("v", "<leader><Enter>", ":.!zsh<CR>", { desc = "Run zsh" })
keymap("n", "gG", "50%", { desc = "Go to middle of file" })
keymap("n", "gf", "<C-W>f", { desc = "Open file in new tab" })
keymap("n", "<leader>bd", ":bufdo bd<CR>", { desc = "Close all buffers" })
keymap("v", "<M-j>", ":move '>+1<CR>gv-gv")
keymap("v", "<M-k>", ":move '<-2<CR>gv-gv")
keymap("v", "gf", "<C-W>f")
keymap("n", "<leader>wk", "<cmd>WhichKey<CR>", { desc = "Which Key" })
keymap("n", "<leader>aa", "<cmd>ZenMode<CR>", { desc = "Zen Mode" })
keymap("n", "<leader>oe", "<cmd>silent !wslview %<CR>", { desc = "Open Externally" })
keymap("n", "<leader>vi", "<cmd>ViewImage<CR>", { desc = "Open Externally" })
keymap("n", "<leader>bb", "<cmd>GitBlameToggle<CR>", { desc = "Toggle git blame" })

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
	keymap("n", "<leader>gs", custom.git_status, { desc = "Git status" })
	keymap("n", "<leader>gc", custom.git_commits, { desc = "Git commits" })
	keymap("n", "<leader>gb", custom.git_bcommits, { desc = "Git bcommits" })
	keymap("n", "<leader>gi", custom.gh_issues, { desc = "Github issues" })
	keymap("n", "<leader>gp", custom.gh_prs, { desc = "Github prs" })
	keymap("n", "<leader>nh", exts.notify.notify, { desc = "Notify history" })
end)

keymap("n", "<leader>fd", "<cmd>GrepInDirectory<CR>", { desc = "Grep in directory" })
keymap("n", "<leader>pd", "<cmd>FileInDirectory<CR>", { desc = "File in directory" })

keymap("n", "<leader><S-TAB>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
keymap("n", "<leader><TAB>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bc", ":BufferLinePickClose<CR>", { desc = "Close buffer" })

-- HARPOON
pcall(function()
	local harpoon_ui = require("harpoon.ui")
	local harpoon_mark = require("harpoon.mark")
	keymap("n", "<leader>ha", harpoon_mark.add_file, { desc = "Add file" })
	keymap("n", "<leader>hh", harpoon_ui.toggle_quick_menu, { desc = "Toggle harpoon" })
	keymap("n", "<leader>hn", harpoon_ui.nav_next, { desc = "Nav next" })
	keymap("n", "<leader>hp", harpoon_ui.nav_prev, { desc = "Nav prev" })
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
