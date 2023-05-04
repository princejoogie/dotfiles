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

require("options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", { ui = { border = "rounded" } })
require("keymaps")
require("commands")

vim.cmd([[
  filetype on
  filetype plugin on
  syntax on
  syntax enable

  autocmd TermOpen * setlocal nonumber norelativenumber

  command Z w | qa
  cabbrev wqa Z
]])
