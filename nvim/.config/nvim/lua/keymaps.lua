local utils = require("utils")
local kmap = utils.kmap

-- OTHER DEFAULT KEYMAPS
-- configs/cmp-config.lua
-- configs/gitsigns-config.lua
-- configs/term-config.lua

-- GENERAL KEYMAPS
kmap("n", "<leader>mm", "<cmd>MarkdownPreview<CR>")
kmap("n", "<leader>va", "<S-v>$hh%k<CR>")
kmap("n", "<leader>-", ":resize +5<CR>")
kmap("n", "<leader>=", ":resize -5<CR>")
kmap("n", "<leader><", ":vertical resize +5<CR>")
kmap("n", "<leader>>", ":vertical resize -5<CR>")
kmap("n", "gf", "<C-W>f")
kmap("v", "gf", "<C-W>f")
kmap("v", "<A-j>", ":move '>+1<CR>gv-gv")
kmap("v", "<A-k>", ":move '<-2<CR>gv-gv")
kmap("i", "jj", "<Esc>")
kmap("n", "<C-n>", ":noh<CR>")
kmap("n", "<C-z>", "<Nop>")
kmap("n", "<C-s>", ":w<CR>")
kmap("n", "<C-b>", "<cmd>NERDTreeToggle<CR>", {})
kmap("n", "<leader>p", ":Format<CR>")

-- LSP
-- see configs/lsp-config.lua
kmap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>")
kmap("n", "<leader>dk", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
kmap("n", "<leader>dj", "<cmd>lua vim.diagnostic.goto_next()<CR>")
kmap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")

-- FUGITIVE
kmap("n", "<leader>gh", "<cmd>diffget //3<CR>")
kmap("n", "<leader>gf", "<cmd>diffget //2<CR>")

-- TELESCOPE
local builtin = '<cmd>lua require("telescope.builtin").'
local tconfig = '<cmd>lua require("configs.telescope-config").'
kmap("n", "<C-p>", builtin .. "find_files()<CR>")
kmap("n", "<C-f>", builtin .. "live_grep()<CR>")
kmap("n", "<leader>fw", builtin .. "grep_string()<CR>")
kmap("n", "<leader>fb", builtin .. "current_buffer_fuzzy_find()<CR>")
kmap("n", "<leader>fh", builtin .. "help_tags()<CR>")
kmap("n", "<leader>gs", builtin .. "git_status()<CR>")
kmap("n", "<leader>ts", builtin .. "treesitter()<CR>")
kmap("n", "<leader>ch", builtin .. "command_history()<CR>")
kmap("n", "<leader>gi", tconfig .. "gh_issues()<CR>")
kmap("n", "<leader>gp", tconfig .. "gh_prs()<CR>")
kmap("n", "<leader>gi", tconfig .. "gh_issues()<CR>")

-- BARBAR
kmap("n", "<leader><S-TAB>", ":BufferPrevious<CR>")
kmap("n", "<leader><TAB>", ":BufferNext<CR>")
kmap("n", "<A-h>", ":BufferMovePrevious<CR>")
kmap("n", "<A-l>", " :BufferMoveNext<CR>")
kmap("n", "<leader>1", ":BufferGoto 1<CR>")
kmap("n", "<leader>2", ":BufferGoto 2<CR>")
kmap("n", "<leader>3", ":BufferGoto 3<CR>")
kmap("n", "<leader>4", ":BufferGoto 4<CR>")
kmap("n", "<leader>5", ":BufferGoto 5<CR>")
kmap("n", "<leader>6", ":BufferGoto 6<CR>")
kmap("n", "<leader>7", ":BufferGoto 7<CR>")
kmap("n", "<leader>8", ":BufferGoto 8<CR>")
kmap("n", "<leader>9", ":BufferGoto 9<CR>")
kmap("n", "<leader>0", ":BufferLast<CR>")
kmap("n", "<leader>bc", ":BufferClose<CR>")

-- NVIM-DAP
local dap_base = '<cmd>lua require("dap").'
local dap_ui = '<cmd>lua require("dapui").'
kmap("n", "<leader>dp", dap_base .. "continue()<CR>")
kmap("n", "<leader>do", dap_base .. "step_over()<CR>")
kmap("n", "<leader>dn", dap_base .. "step_into()<CR>")
kmap("n", "<leader>dN", dap_base .. "step_out()<CR>")
kmap("n", "<leader>db", dap_base .. "toggle_breakpoint()<CR>")
kmap("n", "<leader>dB", dap_base .. 'set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
kmap("n", "<leader>dr", dap_base .. "repl.toggle()<CR>")
kmap("n", "<leader>dt", dap_ui .. "toggle()<CR>")

-- TODO-COMMENTS
kmap("n", "<leader>tl", ":TodoQuickFix<CR>")
kmap("n", "<leader>tt", ":TodoTelescope<CR>")

-- HARPOON
local harpoon_ui = '<cmd>lua require("harpoon.ui").'
local harpoon_mark = '<cmd>lua require("harpoon.mark").'
kmap("n", "<leader>hh", harpoon_ui .. "toggle_quick_menu()<CR>")
kmap("n", "<leader>hn", harpoon_ui .. "nav_next()<CR>")
kmap("n", "<leader>hp", harpoon_ui .. "nav_prev()<CR>")
kmap("n", "<leader>ha", harpoon_mark .. "add_file()<CR>")

-- PACKAGE-INFO
kmap("n", "<leader>ns", ":lua require('package-info').show()<CR>")
kmap("n", "<leader>nc", ":lua require('package-info').hide()<CR>")
kmap("n", "<leader>nu", ":lua require('package-info').update()<CR>")
kmap("n", "<leader>nd", ":lua require('package-info').delete()<CR>")
kmap("n", "<leader>ni", ":lua require('package-info').install()<CR>")
kmap("n", "<leader>nr", ":lua require('package-info').reinstall()<CR>")
kmap("n", "<leader>np", ":lua require('package-info').change_version()<CR>")
