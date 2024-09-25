local opt = vim.opt

opt.laststatus = 3
opt.showmode = false
opt.clipboard = "unnamedplus"
opt.cursorline = true

-- Indenting
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.autoindent = true
opt.tabstop = 2
opt.softtabstop = 2
opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- Numbers
opt.number = true
opt.numberwidth = 2
opt.ruler = false
opt.nu = true
opt.rnu = true
opt.scrolloff = 10
opt.swapfile = false
opt.writebackup = false

-- disable nvim intro
opt.shortmess:append("sI")
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.wrap = true

-- interval for writing swap file to disk, also used by gitsigns
opt.updatetime = 150

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append("<>[]hl")

-- disable some default providers
for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
	vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath("data") .. "/mason/bin"

if os.getenv("CONDA_PREFIX") then
	vim.g.python3_host_prog = os.getenv("CONDA_PREFIX") .. "/bin/python"
end

-- allow looping back in qf list
vim.cmd([[
	command! Cnext try | cnext | catch | cfirst | catch | endtry
	command! Cprev try | cprev | catch | clast | catch | endtry

	command! Lnext try | lnext | catch | lfirst | catch | endtry
	command! Lprev try | lprev | catch | llast | catch | endtry
]])
