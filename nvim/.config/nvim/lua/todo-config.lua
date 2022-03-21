local todo = require('todo-comments')
todo.setup()

local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap("n", "<leader>tl", ":TodoQuickFix<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>tt", ":TodoTelescope<CR>", opts)

