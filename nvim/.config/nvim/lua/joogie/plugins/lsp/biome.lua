local util = require("lspconfig.util")

local root_dir = util.root_pattern("biome.json")(vim.fs.cwd())

if not root_dir then
  return {}
end

return {
  root_dir = root_dir,
  cmd = { "biome", "lsp-proxy" },
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
  single_file_support = false,
}
