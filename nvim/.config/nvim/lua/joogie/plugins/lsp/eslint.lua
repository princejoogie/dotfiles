local root_dir = vim.fs.dirname(vim.fs.find(".git", { path = vim.fs.cwd(), upward = true })[1])

if vim.uv.fs_stat(root_dir .. "/biome.json") then
  return {}
end

return {
  root_dir = root_dir,
}
