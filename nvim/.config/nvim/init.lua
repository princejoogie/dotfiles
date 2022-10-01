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

local options = {
  autoindent = true,
  autoread = true,
  background = "dark",
  clipboard = "unnamedplus",
  encoding = "UTF-8",
  cursorline = true,
  expandtab = true,
  foldlevel = 2,
  foldmethod = "syntax",
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
  termguicolors = true
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd [[
  filetype on
  filetype plugin on
  syntax on
  syntax enable

  colorscheme tokyodark
  autocmd TermOpen * setlocal nonumber norelativenumber
]]

require("options")
require("plugins")
require("keymaps")
require("lsp")
