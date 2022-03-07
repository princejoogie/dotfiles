" https://github.com/princejoogie/dotfiles

" set rtp+="$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim"
call plug#begin(stdpath('data'))

Plug 'ThePrimeagen/harpoon'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'github/copilot.vim'
Plug 'haishanh/night-owl.vim'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/vim-vsnip'
Plug 'jiangmiao/auto-pairs'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp-status.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'williamboman/nvim-lsp-installer'

call plug#end()

let mapleader=' '

" LUA CONFIGURATIONS
lua require('lsp-config')
lua require('cmp-config')

" PRETTEIR SETTINGS
nmap <leader>f :Prettier<CR>

" TELESCOPE SETTINGS
nnoremap <C-p> <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <C-f> <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

" HARPOON SETTINGS ----------------------
nnoremap <leader>hh <cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>
nnoremap <leader>hn <cmd>lua require('harpoon.ui').nav_next()<CR>
nnoremap <leader>hp <cmd>lua require('harpoon.ui').nav_prev()<CR>
nnoremap <leader>ha <cmd>lua require('harpoon.mark').add_file()<CR>

" AIRLINE SETTINGS
let g:airline_theme='deus'

" NERDTREE SETTINGS
nnoremap <C-b> :NERDTreeToggle<CR>
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

"  GENERAL SETTINGS ----------------------
colorscheme night-owl
filetype on
filetype plugin on
syntax on
syntax enable

nnoremap <leader>- :resize +5<CR>
nnoremap <leader>= :resize -5<CR>
nnoremap <leader>< :vertical resize +5<CR>
nnoremap <leader>> :vertical resize -5<CR>
nnoremap <leader><TAB> :bnext<CR>
nnoremap <leader><S-TAB> :bprev<CR>

inoremap jj <Esc>
nnoremap <C-n> :noh<CR>
nnoremap <C-z> <Nop>
noremap <C-s> :w<CR>
vmap <C-c> "*y<CR>

set background=dark
set encoding=UTF-8
set hlsearch
set ignorecase
set incsearch
set nobackup
set noshowmode
set noswapfile
set nowritebackup
set rnu
set shiftwidth=2
set smartcase
set smarttab
set tabstop=2
set termguicolors

