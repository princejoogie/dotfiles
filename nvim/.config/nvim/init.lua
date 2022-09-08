--        _                   _
--       (_)___  ____  ____ _(_)__
--      / / __ \/ __ \/ __ `/ / _ \
--     / / /_/ / /_/ / /_/ / /  __/
--  __/ /\____/\____/\__, /_/\___/
-- /___/            /____/
--
-- Github    - @princejoogie
-- Instagram - @princecaarlo
-- Twitter   - @princecaarlo

vim.cmd [[
  let s:clip = '/mnt/c/Windows/System32/clip.exe'
  if executable(s:clip)
    augroup WSLYank
      autocmd!
      autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup end
  endif
]]

vim.g.mapleader = " "
vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.background = "dark"
vim.opt.clipboard = "unnamedplus"
vim.opt.encoding = "UTF-8"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.foldlevel = 2
vim.opt.foldmethod = "syntax"
vim.opt.foldnestmax = 10
vim.opt.laststatus = 3
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.mouse = "a"
vim.opt.backup = false
vim.opt.foldenable = false
vim.opt.showmode = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.nu = true
vim.opt.rnu = true
vim.opt.shiftwidth = 2
vim.opt.smartcase = true
vim.opt.smarttab = true
vim.opt.softtabstop = 0
vim.opt.tabstop = 2
vim.opt.termguicolors = true

vim.cmd [[
  filetype on
  filetype plugin on
  syntax on
  syntax enable

  let g:tokyodark_enable_italic_comment = 0
  let g:tokyodark_enable_italic = 0
  colorscheme tokyodark

  autocmd TermOpen * setlocal nonumber norelativenumber
]]

local status = pcall(require, "impatient")
if (not status) then
  vim.notify("impatient not found")
end
require("plugins")
require("keymaps")
