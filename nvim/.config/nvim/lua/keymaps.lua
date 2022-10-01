local keymap = require("utils").keymap

-- GENERAL KEYMAPS
keymap("i", "jj", "<Esc>")
keymap("n", "<A-j>", ":resize -5<CR>")
keymap("n", "<A-k>", ":resize +5<CR>")
keymap("n", "<A-l>", ":vertical resize -5<CR>")
keymap("n", "<A-h>", ":vertical resize +5<CR>")
keymap("n", "<C-b>", ":NvimTreeToggle<CR>")
keymap("n", "<C-n>", ":noh<CR>")
keymap("n", "<C-s>", ":w<CR>")
keymap("n", "<C-z>", "<Nop>")
keymap("n", "<leader>hg", ":TSHighlightCapturesUnderCursor<CR>")
keymap("n", "<leader>mm", ":MarkdownPreview<CR>")
keymap("n", "<leader>p", ":Format<CR>")
keymap("n", "<leader>d", '"_d')
keymap("v", "<leader>d", '"_d')
keymap("v", "<C-p>", '"_dP')
keymap("n", "<leader>qn", ":cn<CR>")
keymap("n", "<leader>qp", ":cp<CR>")
keymap("n", "<leader>qf", ":copen<CR>")
keymap("n", "<leader><Enter>", ":.!zsh<CR>")
keymap("v", "<leader><Enter>", ":.!zsh<CR>")
keymap("n", "<leader>va", "<S-v>$hh%k<CR>")
keymap("n", "gG", "50%")
keymap("n", "gf", "<C-W>f")
keymap("v", "<A-j>", ":move '>+1<CR>gv-gv")
keymap("v", "<A-k>", ":move '<-2<CR>gv-gv")
keymap("v", "gf", "<C-W>f")

-- LSP
local diag = vim.diagnostic
keymap("n", "<leader>dj", diag.goto_next)
keymap("n", "<leader>dk", diag.goto_prev)
keymap("n", "<leader>e", diag.open_float)
keymap("n", "<leader>q", diag.setloclist)

-- FUGITIVE
keymap("n", "<leader>gf", ":diffget //2<CR>")
keymap("n", "<leader>gh", ":diffget //3<CR>")

-- TELESCOPE
pcall(
  function()
    local builtin = require("telescope.builtin")
    local custom = require("configs.telescope")
    keymap("n", "<C-f>", builtin.live_grep)
    keymap("n", "<C-p>", "<cmd>Telescope find_files hidden=true no_ignore=true<CR>")
    keymap("n", "<leader>ch", builtin.command_history)
    keymap("n", "<leader>fb", builtin.current_buffer_fuzzy_find)
    keymap("n", "<leader>fh", builtin.help_tags)
    keymap("n", "<leader>fw", builtin.grep_string)
    keymap("n", "<leader>gs", builtin.git_status)
    keymap("n", "<leader>ts", builtin.treesitter)
    keymap("n", "<leader>nh", "<cmd>Telescope notify<CR>")
    keymap("n", "<leader>gi", custom.gh_issues)
    keymap("n", "<leader>gp", custom.gh_prs)
  end
)

-- BARBAR
keymap("n", "<leader>0", ":BufferLast<CR>")
keymap("n", "<leader>1", ":BufferGoto 1<CR>")
keymap("n", "<leader>2", ":BufferGoto 2<CR>")

keymap("n", "<leader>3", ":BufferGoto 3<CR>")
keymap("n", "<leader>4", ":BufferGoto 4<CR>")
keymap("n", "<leader>5", ":BufferGoto 5<CR>")
keymap("n", "<leader>6", ":BufferGoto 6<CR>")
keymap("n", "<leader>7", ":BufferGoto 7<CR>")
keymap("n", "<leader>8", ":BufferGoto 8<CR>")
keymap("n", "<leader>9", ":BufferGoto 9<CR>")
keymap("n", "<leader><S-TAB>", ":BufferPrevious<CR>")
keymap("n", "<leader><TAB>", ":BufferNext<CR>")
keymap("n", "<leader>bc", ":BufferClose<CR>")

-- NVIM-DAP
pcall(
  function()
    local dap_base = require("dap")
    local dap_ui = require("dapui")
    keymap("n", "<leader>dN", dap_base.step_out)
    keymap("n", "<leader>db", dap_base.toggle_breakpoint)
    keymap("n", "<leader>dn", dap_base.step_into)
    keymap("n", "<leader>do", dap_base.step_over)
    keymap("n", "<leader>dp", dap_base.continue)
    keymap(
      "n",
      "<leader>dB",
      function()
        dap_base.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end
    )
    keymap("n", "<leader>dr", dap_base.repl.toggle)
    keymap("n", "<leader>dt", dap_ui.toggle)
  end
)

-- HARPOON
pcall(
  function()
    local harpoon_ui = require("harpoon.ui")
    local harpoon_mark = require("harpoon.mark")
    keymap("n", "<leader>ha", harpoon_mark.add_file)
    keymap("n", "<leader>hh", harpoon_ui.toggle_quick_menu)
    keymap("n", "<leader>hn", harpoon_ui.nav_next)
    keymap("n", "<leader>hp", harpoon_ui.nav_prev)
  end
)

-- PACKAGE-INFO
pcall(
  function()
    local pi_base = require("package-info")
    keymap("n", "<leader>nc", pi_base.hide)
    keymap("n", "<leader>nd", pi_base.delete)
    keymap("n", "<leader>ni", pi_base.install)
    keymap("n", "<leader>np", pi_base.change_version)
    keymap("n", "<leader>nr", pi_base.reinstall)
    keymap("n", "<leader>ns", pi_base.show)
    keymap("n", "<leader>nu", pi_base.update)
  end
)
