local opts = { noremap = true, silent = true }

-- Move to previous/next
vim.api.nvim_set_keymap('n', '<leader><S-TAB>', ':BufferPrevious<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader><TAB>', ':BufferNext<CR>', opts)
-- Re-order to previous/next
vim.api.nvim_set_keymap('n', '<A-h>', ':BufferMovePrevious<CR>', opts)
vim.api.nvim_set_keymap('n', '<A-l>', ' :BufferMoveNext<CR>', opts)
-- Goto buffer in position...
vim.api.nvim_set_keymap('n', '<leader>1', ':BufferGoto 1<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>2', ':BufferGoto 2<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>3', ':BufferGoto 3<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>4', ':BufferGoto 4<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>5', ':BufferGoto 5<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>6', ':BufferGoto 6<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>7', ':BufferGoto 7<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>8', ':BufferGoto 8<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>9', ':BufferGoto 9<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>0', ':BufferLast<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>bc', ':BufferClose<CR>', opts)

