local paths = vim.split(vim.fn.glob("~/.config/nvim/lua/*/*lua"), "\n")

-- Source all files under the lua/configs directory
for _, file in pairs(paths) do
  vim.cmd("source " .. file)
end

vim.cmd(
  [[
    let g:NERDCommentEmptyLines = 1
    let g:NERDCreateDefaultMappings = 1
    let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
    let g:NERDSpaceDelims = 1
    let g:NERDToggleCheckAllLines = 1
    let g:NERDTreeDirArrowCollapsible = ''
    let g:NERDTreeDirArrowExpandable = ''
    let g:NERDTreeHighlightCursorline = 1
    let g:NERDTreeShowHidden = 1
    let g:NERDTrimTrailingWhitespace = 1
    let g:closetag_emptyTags_caseSensitive = 1
    let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.jsx,*.tsx,*.js'
    let g:closetag_filetypes = 'html,xhtml,phtml,jsx,tsx,js'
    let g:closetag_shortcut = '>'
    let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.tsx,*.js'
    let g:closetag_xhtml_filetypes = 'xhtml,jsx,tsx,js'
    let g:nerdtree_sync_cursorline = 1
]]
)

vim.cmd(
  [[
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists('s:std_in') && v:this_session == '' | NERDTree | endif
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
]]
)

vim.cmd(
  [[
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
]]
)
