local utils = require("utils")
local map = utils.map

-- OTHER DEFAULT KEYMAPS
-- configs/
-- -> cmp-config.lua
-- -> gitsigns-config.lua
-- -> term-config.lua

-- FORMATTER
map("n", "<leader>p", ":Format<CR>")

-- LSP
-- see configs/lsp-config.lua
map("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>")
map("n", "<leader>dk", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
map("n", "<leader>dj", "<cmd>lua vim.diagnostic.goto_next()<CR>")
map("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")

-- TELESCOPE
local builtin = '<cmd>lua require("telescope.builtin").'
local tconfig = '<cmd>lua require("configs.telescope-config").'
map("n", "<C-p>", builtin .. "find_files()<CR>")
map("n", "<C-f>", builtin .. "live_grep()<CR>")
map("n", "<leader>fw", builtin .. "grep_string()<CR>")
map("n", "<leader>fb", builtin .. "current_buffer_fuzzy_find()<CR>")
map("n", "<leader>fh", builtin .. "help_tags()<CR>")
map("n", "<leader>gs", builtin .. "git_status()<CR>")
map("n", "<leader>ts", builtin .. "treesitter()<CR>")
map("n", "<leader>ch", builtin .. "command_history()<CR>")
map("n", "<leader>gi", tconfig .. "gh_issues()<CR>")
map("n", "<leader>gp", tconfig .. "gh_prs()<CR>")
map("n", "<leader>gi", tconfig .. "gh_issues()<CR>")

-- BARBAR
map("n", "<leader><S-TAB>", ":BufferPrevious<CR>")
map("n", "<leader><TAB>", ":BufferNext<CR>")
map("n", "<A-h>", ":BufferMovePrevious<CR>")
map("n", "<A-l>", " :BufferMoveNext<CR>")
map("n", "<leader>1", ":BufferGoto 1<CR>")
map("n", "<leader>2", ":BufferGoto 2<CR>")
map("n", "<leader>3", ":BufferGoto 3<CR>")
map("n", "<leader>4", ":BufferGoto 4<CR>")
map("n", "<leader>5", ":BufferGoto 5<CR>")
map("n", "<leader>6", ":BufferGoto 6<CR>")
map("n", "<leader>7", ":BufferGoto 7<CR>")
map("n", "<leader>8", ":BufferGoto 8<CR>")
map("n", "<leader>9", ":BufferGoto 9<CR>")
map("n", "<leader>0", ":BufferLast<CR>")
map("n", "<leader>bc", ":BufferClose<CR>")

-- NVIM-DAP
local dap_base = '<cmd>lua require("dap").'
local dap_ui = '<cmd>lua require("dapui").'
map("n", "<leader>dp", dap_base .. "continue()<CR>")
map("n", "<leader>do", dap_base .. "step_over()<CR>")
map("n", "<leader>dn", dap_base .. "step_into()<CR>")
map("n", "<leader>dN", dap_base .. "step_out()<CR>")
map("n", "<leader>db", dap_base .. "toggle_breakpoint()<CR>")
map("n", "<leader>dB", dap_base .. 'set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
map("n", "<leader>dr", dap_base .. "repl.toggle()<CR>")
map("n", "<leader>dt", dap_ui .. "toggle()<CR>")

-- TODO-COMMENTS
map("n", "<leader>tl", ":TodoQuickFix<CR>")
map("n", "<leader>tt", ":TodoTelescope<CR>")

-- HARPOON
local harpoon_ui = '<cmd>lua require("harpoon.ui").'
local harpoon_mark = '<cmd>lua require("harpoon.mark").'
map("n", "<leader>hh", harpoon_ui .. "toggle_quick_menu()<CR>")
map("n", "<leader>hn", harpoon_ui .. "nav_next()<CR>")
map("n", "<leader>hp", harpoon_ui .. "nav_prev()<CR>")
map("n", "<leader>ha", harpoon_mark .. "add_file()<CR>")

-- PACKAGE-INFO
map("n", "<leader>ns", ":lua require('package-info').show()<CR>")
map("n", "<leader>nc", ":lua require('package-info').hide()<CR>")
map("n", "<leader>nu", ":lua require('package-info').update()<CR>")
map("n", "<leader>nd", ":lua require('package-info').delete()<CR>")
map("n", "<leader>ni", ":lua require('package-info').install()<CR>")
map("n", "<leader>nr", ":lua require('package-info').reinstall()<CR>")
map("n", "<leader>np", ":lua require('package-info').change_version()<CR>")
