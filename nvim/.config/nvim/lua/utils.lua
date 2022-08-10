local M = {}

M.keymap = function(mode, lhs, rhs, opts)
  local def_opts = {noremap = true, silent = true}
  if opts == nil then
    opts = {}
  end

  local keyopts = vim.tbl_extend("force", def_opts, opts)

  if lhs == nil then
    lhs = ""
  end

  if rhs == nil then
    rhs = ""
  end
  vim.keymap.set(mode, lhs, rhs, keyopts)
end

M.bmap = function(bufnr, mode, lhs, rhs, opts)
  local def_opts = {noremap = true, silent = true}
  if opts == nil then
    opts = {}
  end

  local keyopts = vim.tbl_extend("force", def_opts, opts)
  vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, keyopts)
end

M.bopts = function(bufnr, lhs, rhs)
  vim.api.nvim_buf_set_option(bufnr, lhs, rhs)
end

M.icons = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
  Spinner = {
    "⣾",
    "⣷",
    "⣯",
    "⣟",
    "⡿",
    "⢿",
    "⣻",
    "⣽"
  }
}

return M
