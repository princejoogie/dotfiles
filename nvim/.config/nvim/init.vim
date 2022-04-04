" https://github.com/princejoogie/dotfiles
source ~/.config/nvim/plugins.vim

let mapleader=' '

if has('nvim') && executable('nvr')
  let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
endif

" WSL Yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if executable(s:clip)
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif

filetype on
filetype plugin on
syntax on
syntax enable

let g:tokyodark_enable_italic_comment = 0
let g:tokyodark_enable_italic = 0
colorscheme tokyodark

" LUA CONFIGURATIONS
lua require('impatient').enable_profile()
lua require('configs')
lua require('keymaps')

" NIGHTLY SETTINGS
set laststatus=3
highlight WinSeparator guibg=None guifg=#1A1B2A

if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

