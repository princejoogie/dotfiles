local keymap = vim.keymap.set

local cmd = function(command)
	return "<cmd>" .. command .. "<CR>"
end

-- General Editing
keymap("i", "<C-h>", "<C-w>", { desc = "Delete word back" })
keymap("i", "<C-l>", "<Esc>ldwi", { desc = "Delete word front" })
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap("n", "n", "nzz", { desc = "Match next" })
keymap("n", "N", "Nzz", { desc = "Match previous" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
keymap("x", "<leader>d", '"_d', { desc = "Delete without putting to register" })
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
keymap("n", "<C-w>z", cmd("tab split"), { desc = "Open buffer in new Tab" })
keymap("n", "<leader><Tab>", cmd("tabnext"), { desc = "Next Tab" })
keymap("n", "<leader><S-Tab>", cmd("tabprevious"), { desc = "Previous Tab" })

-- Search and Replace
keymap("n", "<C-n>", cmd("noh"), { desc = "Clear search highlights" })
keymap("n", "<leader>cp", [[:let @+=expand('%:~:.')<CR>]], { desc = "Copy relative path" })

-- File Navigation
keymap("n", "<C-b>", cmd("Neotree toggle"), { desc = "Toggle Filetree" })

-- Tmux Integration
keymap("n", "<C-Left>", cmd('lua require("tmux").resize_left()'), { desc = "+ Resize Vertically" })
keymap("n", "<C-Down>", cmd('lua require("tmux").resize_bottom()'), { desc = "+ Resize Horizontally" })
keymap("n", "<C-Up>", cmd('lua require("tmux").resize_top()'), { desc = "- Resize Horizontally" })
keymap("n", "<C-Right>", cmd('lua require("tmux").resize_right()'), { desc = "- Resize Vertically" })
keymap("n", "<C-h>", cmd('lua require("tmux").move_left()'), { desc = "Move to left pane" })
keymap("n", "<C-j>", cmd('lua require("tmux").move_bottom()'), { desc = "Move to bottom pane" })
keymap("n", "<C-k>", cmd('lua require("tmux").move_top()'), { desc = "Move to top pane" })
keymap("n", "<C-l>", cmd('lua require("tmux").move_right()'), { desc = "Move to right pane" })

-- Quickfix
keymap("n", "<leader><S-Tab>", cmd("Cprev"), { desc = "Previous quickfix item" })
keymap("n", "<leader><Tab>", cmd("Cnext"), { desc = "Next quickfix item" })

-- Dadbob
keymap("n", "<leader>db", cmd("DBUIToggle"), { desc = "Toggle DBUI" })

-- Telescope
pcall(function()
	local exts = require("telescope").extensions
	local builtin = require("telescope.builtin")
	keymap("n", "<C-f>", builtin.live_grep, { desc = "Live grep" })
	keymap("n", "<C-p>", builtin.find_files, { desc = "Find files" })
	keymap("n", "<leader>?", function()
		builtin.spell_suggest(require("telescope.themes").get_cursor({}))
	end, { desc = "Spell suggest" })
	keymap("n", "<leader>tr", cmd("Telescope resume"), { desc = "Telescope resume" })
	keymap("n", "<leader>ch", builtin.command_history, { desc = "Command history" })
	keymap("n", "<leader>bf", builtin.buffers, { desc = "Buffers" })
	keymap("n", "<leader>fb", builtin.current_buffer_fuzzy_find, { desc = "Current buffer fuzzy find" })
	keymap("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
	keymap("n", "<leader>fw", builtin.grep_string, { desc = "Grep string" })
	keymap("n", "<leader>ts", builtin.treesitter, { desc = "Treesitter" })
	keymap("n", "<leader>sf", builtin.lsp_document_symbols, { desc = "Document symbols" })
	keymap("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
	keymap("n", "<leader>nh", exts.notify.notify, { desc = "Notify history" })
	keymap("n", "<leader>wt", exts.git_worktree.git_worktree, { desc = "Git Worktree" })
	keymap("n", "<leader>wa", exts.git_worktree.create_git_worktree, { desc = "Create Git Worktree" })
	keymap("n", "<leader>fd", cmd("GrepInDirectory"), { desc = "Grep in directory" })
	keymap("n", "<leader>P", cmd("FileInDirectory"), { desc = "File in directory" })
end)

-- Git Integration
keymap("n", "<leader>gg", cmd("Git"), { desc = "Open Git Fugitive" })
keymap("n", "<leader>gf", cmd("diffget //2"), { desc = "Diff get Current" })
keymap("n", "<leader>gh", cmd("diffget //3"), { desc = "Diff get Head" })
keymap("n", "<leader>dv", cmd("Gvdiffsplit"), { desc = "Diff Vertical" })
keymap("n", "<leader>dh", cmd("Ghdiffsplit"), { desc = "Diff Horizontal" })
keymap("n", "<leader>di", cmd("DiffviewOpen"), { desc = "Diff View Open" })
keymap("n", "<leader>dh", cmd("DiffviewFileHistory"), { desc = "Diff View File History" })
keymap("n", "<leader>dq", cmd("tabc"), { desc = "Close Tab" })

-- Flash
keymap({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
keymap({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })

-- Neotest
pcall(function()
	local neotest = require("neotest")
	keymap("n", "<leader>,", function() end, { desc = "[NeoTest] -->" })
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

-- Spectre
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

-- Harpoon
pcall(function()
	local harpoon_ui = require("harpoon.ui")
	local harpoon_mark = require("harpoon.mark")
	keymap("n", "<leader>ha", harpoon_mark.add_file, { desc = "Add file" })
	keymap("n", "<leader>hh", harpoon_ui.toggle_quick_menu, { desc = "Toggle harpoon" })
end)

-- Notify
keymap("n", "<leader>nd", cmd('lua require("notify").dismiss()'), { desc = "Dismiss notifications" })

-- ChatGPT
keymap("n", "<leader>ai", cmd("ChatGPT"), { desc = "Toggle ChatGPT" })
keymap(
	{ "n", "v", "x" },
	"<leader>ae",
	cmd("ChatGPTEditWithInstructions"),
	{ desc = "Toggle ChatGPTEditWithInstructions" }
)
keymap({ "n", "v", "x" }, "<leader>ar", ":ChatGPTRun", { desc = "ChatGPTRun x" })

-- ZenMode
keymap("n", "<leader>zm", cmd("ZenMode"), { desc = "Toggle ZenMode" })

-- Markdown
keymap("n", "<leader>mm", cmd("MarkdownPreviewToggle"), { desc = "Toggle MarkdownPreview" })

-- Package Info
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

-- WhichKey
keymap("n", "<leader>wk", cmd("WhichKey"), { desc = "Which Key" })

-- Typescript Tools
keymap("n", "<leader>rf", cmd("TSToolsRenameFile"), { desc = "TS Rename File" })

-- Twoslash Queries
keymap("n", "<leader>ti", cmd("TwoslashQueriesInspect"), { desc = "Twoslash Queries toggle" })

-- Code Actions
keymap("n", "<leader>c", function() end, { desc = "[Code Actions] -->" })
