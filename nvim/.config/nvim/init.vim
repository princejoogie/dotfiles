" https://github.com/princejoogie/dotfiles
call plug#begin(stdpath('data'))

" QOL
Plug 'AndrewRadev/tagalong.vim'
Plug 'MunifTanjim/nui.nvim'
Plug 'Shatur/neovim-ayu'
Plug 'ThePrimeagen/harpoon'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'akinsho/bufferline.nvim'
Plug 'akinsho/toggleterm.nvim'
Plug 'alvan/vim-closetag'
Plug 'ap/vim-css-color'
Plug 'arkav/lualine-lsp-progress'
Plug 'github/copilot.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'jiangmiao/auto-pairs'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-telescope/telescope-github.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'onsails/lspkind-nvim'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'sbdchd/neoformat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'vuki656/package-info.nvim'

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'nvim-telescope/telescope-dap.nvim'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'

" LSP
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/vim-vsnip'
Plug 'neovim/nvim-lspconfig'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'

call plug#end()

let mapleader=' '
     
" LUA CONFIGURATIONS
lua require('cmp-config')
lua require('dap-config')
lua require('harpoon-config')
lua require('lsp-config')
lua require('lualine-config')
lua require('package-info-config')
lua require('telescope-config')
lua require('term-config')
lua require('treesitter-config')

" BUFFERLINE SETTINGS
nnoremap <silent><leader>1 <Cmd>BufferLineGoToBuffer 1<CR>
nnoremap <silent><leader>2 <Cmd>BufferLineGoToBuffer 2<CR>
nnoremap <silent><leader>3 <Cmd>BufferLineGoToBuffer 3<CR>
nnoremap <silent><leader>4 <Cmd>BufferLineGoToBuffer 4<CR>
nnoremap <silent><leader>5 <Cmd>BufferLineGoToBuffer 5<CR>
nnoremap <silent><leader>6 <Cmd>BufferLineGoToBuffer 6<CR>
nnoremap <silent><leader>7 <Cmd>BufferLineGoToBuffer 7<CR>
nnoremap <silent><leader>8 <Cmd>BufferLineGoToBuffer 8<CR>
nnoremap <silent><leader>9 <Cmd>BufferLineGoToBuffer 9<CR>

" GITGUTTER SETTINGS
autocmd BufWritePost * GitGutter 
autocmd BufEnter * GitGutterLineNrHighlightsEnable
let g:gitgutter_grep = 'rg'
nmap g<leader>j <Plug>(GitGutterNextHunk)
nmap g<leader>k <Plug>(GitGutterPrevHunk)

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
nnoremap <C-b> <cmd>NERDTreeToggle<CR>
let g:NERDTreeShowHidden = 1
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1
let g:nerdtree_sync_cursorline = 1
let g:NERDTreeHighlightCursorline = 1

" GENERAL SETTINGS ----------------------
autocmd FileType prisma nmap <leader>f :!npx prisma format<CR>
nmap <leader>f <cmd>Neoformat<CR>
nmap <leader>mm <cmd>MarkdownPreview<CR>
nnoremap gf <C-W>f
vnoremap <silent> <A-j> :move '>+1<CR>gv-gv
vnoremap <silent> <A-k> :move '<-2<CR>gv-gv
vnoremap <silent> <leader>f :Neoformat<CR>
vnoremap gf <C-W>f

nnoremap <leader>va <S-v>$hh%k<CR>
nnoremap <leader>- :resize +5<CR>
nnoremap <leader>= :resize -5<CR>
nnoremap <leader>< :vertical resize +5<CR>
nnoremap <leader>> :vertical resize -5<CR>
nnoremap <leader><TAB> :bnext<CR>
nnoremap <leader><S-TAB> :bprev<CR>
nnoremap <leader>ch <cmd>lua require('telescope.builtin').command_history()<CR>
nnoremap <leader>r :NERDTreeFind<CR>zz

inoremap jj <Esc>
nnoremap <C-n> :noh<CR>
nnoremap <C-z> <Nop>
noremap <C-s> :w<CR>
vnoremap <C-c> "*y<CR>
inoremap <C-v> "*p<CR>

set autoindent
set background=dark
set clipboard=unnamedplus
set encoding=UTF-8
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
set softtabstop=0 noexpandtab
set t_Co=256
set tabstop=2
set termguicolors

filetype on
filetype plugin on
syntax on
syntax enable
colorscheme joogie-dark

" NIGHTLY SETTINGS
set laststatus=3
highlight WinSeparator guibg=None guifg=#444444

