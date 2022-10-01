--
--      ██╗ ██████╗  ██████╗  ██████╗ ██╗███████╗
--      ██║██╔═══██╗██╔═══██╗██╔════╝ ██║██╔════╝
--      ██║██║   ██║██║   ██║██║  ███╗██║█████╗
-- ██   ██║██║   ██║██║   ██║██║   ██║██║██╔══╝
-- ╚█████╔╝╚██████╔╝╚██████╔╝╚██████╔╝██║███████╗
--  ╚════╝  ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝╚══════╝
--
-- Github    - @princejoogie
-- Instagram - @princecaarlo
-- Twitter   - @princecaarlo

vim.cmd([[
  let s:clip = '/mnt/c/Windows/System32/clip.exe'
  if executable(s:clip)
    augroup WSLYank
      autocmd!
      autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup end
  endif
]])

vim.g.mapleader = " "

local opts = {
	autoindent = true,
	autoread = true,
	background = "dark",
	clipboard = "unnamedplus",
	encoding = "UTF-8",
	cursorline = true,
	expandtab = true,
	foldlevel = 2,
	foldmethod = "manual",
	foldnestmax = 10,
	laststatus = 3,
	hidden = true,
	hlsearch = true,
	ignorecase = true,
	incsearch = true,
	mouse = "a",
	backup = false,
	foldenable = false,
	showmode = false,
	swapfile = false,
	writebackup = false,
	nu = true,
	rnu = true,
	shiftwidth = 2,
	smartcase = true,
	smarttab = true,
	softtabstop = 0,
	tabstop = 2,
	termguicolors = true,
	ch = 0,
}

for k, v in pairs(opts) do
	vim.opt[k] = v
end

vim.g.nabi_transparent_background = true
vim.g.nabi_enable_italic = false
vim.g.nabi_enable_italic_comment = false

vim.cmd([[
  filetype on
  filetype plugin on
  syntax on
  syntax enable

  colorscheme nabi
  autocmd TermOpen * setlocal nonumber norelativenumber
]])

require("plugins")
require("keymaps")
require("lsp")
