local paths = vim.split(vim.fn.glob('~/.config/nvim/lua/*/*lua'), '\n')

for i, file in pairs(paths) do
  vim.cmd('source ' .. file)
end