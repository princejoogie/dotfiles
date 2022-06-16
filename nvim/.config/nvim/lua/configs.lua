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
    let g:NERDTrimTrailingWhitespace = 1
    let g:closetag_emptyTags_caseSensitive = 1
    let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.jsx,*.tsx,*.js'
    let g:closetag_filetypes = 'html,xhtml,phtml,jsx,tsx,js'
    let g:closetag_shortcut = '>'
    let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.tsx,*.js'
    let g:closetag_xhtml_filetypes = 'xhtml,jsx,tsx,js'
]]
)

vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.background = "dark"
vim.opt.clipboard = "unnamedplus"
vim.opt.encoding = "UTF-8"
vim.opt.expandtab = true
vim.opt.foldlevel = 2
vim.opt.foldmethod = "syntax"
vim.opt.foldnestmax = 10
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
