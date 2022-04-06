"        _                   _
"       (_)___  ____  ____ _(_)__
"      / / __ \/ __ \/ __ `/ / _ \
"     / / /_/ / /_/ / /_/ / /  __/
"  __/ /\____/\____/\__, /_/\___/
" /___/            /____/
"
" Github    - @princejoogie
" Instagram - @princecaarlo
" Twitter   - @princecaarlo

" Load Plugins
source ~/.config/nvim/plugins.vim

let mapleader=' '

function! AddSubtract(char, back)
  let pattern = &nrformats =~ 'alpha' ? '[[:alpha:][:digit:]]' : '[[:digit:]]'
  call search(pattern, 'cw' . a:back)
  execute 'normal! ' . v:count1 . a:char
  silent! call repeat#set(":\<C-u>call AddSubtract('" .a:char. "', '" .a:back. "')\<CR>")
endfunction
nnoremap <silent>         <C-a> :<C-u>call AddSubtract("\<C-a>", '')<CR>
nnoremap <silent> <Leader><C-a> :<C-u>call AddSubtract("\<C-a>", 'b')<CR>
nnoremap <silent>         <C-x> :<C-u>call AddSubtract("\<C-x>", '')<CR>
nnoremap <silent> <Leader><C-x> :<C-u>call AddSubtract("\<C-x>", 'b')<CR>

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

