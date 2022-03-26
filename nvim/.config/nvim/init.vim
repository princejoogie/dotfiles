" https://github.com/princejoogie/dotfiles
call plug#begin(stdpath('data'))

" QOL
Plug 'AndrewRadev/tagalong.vim'
Plug 'MunifTanjim/nui.nvim'
Plug 'Shatur/neovim-ayu'
Plug 'ThePrimeagen/harpoon'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'akinsho/toggleterm.nvim'
Plug 'alvan/vim-closetag'
Plug 'djoshea/vim-autoread'
Plug 'folke/todo-comments.nvim'
Plug 'github/copilot.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'jiangmiao/auto-pairs'
Plug 'kdheepak/lazygit.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'lewis6991/gitsigns.nvim'
Plug 'mhartington/formatter.nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-telescope/telescope-github.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'princejoogie/tailwind-highlight.nvim', {'branch': 'dev'}
Plug 'romgrk/barbar.nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'vuki656/package-info.nvim'

"Color schemes
Plug 'tiagovla/tokyodark.nvim'

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'nvim-telescope/telescope-dap.nvim'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'

" LSP
Plug 'arkav/lualine-lsp-progress'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/nvim-cmp', {'branch': 'dev'}
Plug 'hrsh7th/vim-vsnip'
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'williamboman/nvim-lsp-installer'

call plug#end()

let mapleader=' '

if has('nvim') && executable('nvr')
  let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
endif

" FUGITIVE SETTINGS
nmap <leader>gh <cmd>diffget //3<CR>
nmap <leader>gf <cmd>diffget //2<CR>

" CLOSETAG SETTINGS
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.jsx,*.tsx,*.js'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.tsx,*.js'
let g:closetag_filetypes = 'html,xhtml,phtml,jsx,tsx,js'
let g:closetag_xhtml_filetypes = 'xhtml,jsx,tsx,js'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_shortcut = '>'

" NERDTREE SETTINGS
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') && v:this_session == '' | NERDTree | endif
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
nnoremap <C-b> <cmd>NERDTreeToggle<CR>
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let g:NERDTreeShowHidden = 1
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1
let g:nerdtree_sync_cursorline = 1
let g:NERDTreeHighlightCursorline = 1

" GENERAL SETTINGS ----------------------
nmap <leader>mm <cmd>MarkdownPreview<CR>
nnoremap gf <C-W>f
vnoremap gf <C-W>f
vnoremap <silent> <A-j> :move '>+1<CR>gv-gv
vnoremap <silent> <A-k> :move '<-2<CR>gv-gv

nnoremap <leader>va <S-v>$hh%k<CR>
nnoremap <leader>- :resize +5<CR>
nnoremap <leader>= :resize -5<CR>
nnoremap <leader>< :vertical resize +5<CR>
nnoremap <leader>> :vertical resize -5<CR>

inoremap jj <Esc>
nnoremap <C-n> :noh<CR>
nnoremap <C-z> <Nop>
noremap <C-s> :w<CR>

" WSL Yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if executable(s:clip)
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif

set autoindent
set autoread
set background=dark
set clipboard=unnamedplus
set encoding=UTF-8
set expandtab
set foldlevel=2
set foldmethod=syntax
set foldnestmax=10
set hidden
set hlsearch
set ignorecase
set incsearch
set mouse=a
set nobackup
set nofoldenable
set noshowmode
set noswapfile
set nowritebackup
set nu rnu
set shiftwidth=2
set smartcase
set smarttab
set softtabstop=0
set t_Co=256
set tabstop=2
set termguicolors

filetype on
filetype plugin on
syntax on
syntax enable

let g:tokyodark_enable_italic_comment = 0
let g:tokyodark_enable_italic = 0
colorscheme tokyodark

" LUA CONFIGURATIONS
lua require('barbar-config')
lua require('cmp-config')
lua require('colorizer-config')
lua require('dap-config')
lua require('formatter-config')
lua require('gitsigns-config')
lua require('harpoon-config')
lua require('lsp-config')
lua require('lualine-config')
lua require('package-info-config')
lua require('telescope-config')
lua require('term-config')
lua require('todo-config')
lua require('treesitter-config')

" NIGHTLY SETTINGS
set laststatus=3
highlight WinSeparator guibg=None guifg=#1A1B2A

if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

