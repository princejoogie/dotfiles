local M = {}

--- Maps a key to a command.
---
-- @param mode - <n|i|v|x|...>
-- @param lhs - left hand side of the keymap
-- @param rhs - right hand side of the keymap
-- @param opts - additional options
--
-- @example
-- ```lua
-- map('n', '<leader>o', ':Open<CR>')
-- ```
M.kmap = function(mode, lhs, rhs, opts)
  local def_opts = { noremap = true, silent = true }
  if opts == nil then
    opts = {}
  end

  local keyopts = vim.tbl_extend('force', def_opts, opts)
  vim.api.nvim_set_keymap(mode, lhs, rhs, keyopts)
end

--- Maps a key to a command. (requires >0.7)
---
-- @param mode {string|array} - <n|i|v|x|...>
-- @param lhs {string} - left hand side of the keymap
-- @param rhs {string|function} - right hand side of the keymap
-- @param opts {table} - see :map-arguments
--
-- @example
-- ```lua
-- map('n', '<leader>o', function() return print("Hello World") end)
-- ```
M.keymap = function(mode, lhs, rhs, opts)
  local def_opts = { noremap = true, silent = true }
  if opts == nil then
    opts = {}
  end

  local keyopts = vim.tbl_extend('force', def_opts, opts)
  vim.keymap.set(mode, lhs, rhs, keyopts)
end

--- Maps a key to a command in a specific buffer.
---
-- @param bufnr - buffer number
-- @param mode - <n|i|v|x|...>
-- @param lhs - left hand side of the keymap
-- @param rhs - right hand side of the keymap
-- @param opts - additional options
--
-- @example
-- ```lua
-- map('n', '<leader>o', ':Open<CR>')
-- ```
M.bmap = function(bufnr, mode, lhs, rhs, opts)
  local def_opts = { noremap = true, silent = true }
  if opts == nil then
    opts = {}
  end

  local keyopts = vim.tbl_extend('force', def_opts, opts)
  vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, keyopts)
end

--- Sets option for a specific buffer.
---
-- @param bufnr - buffer number
-- @param lhs - left hand side of the keymap
-- @param rhs - right hand side of the keymap
--
-- @example
-- ```lua
-- map(bufnr, '<leader>o', ':Open<CR>')
-- ```
M.bopts = function(bufnr, lhs, rhs)
  vim.api.nvim_buf_set_option(bufnr, lhs, rhs)
end

return M
