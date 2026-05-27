local function is_in_dir(path, dir)
  path = vim.fs.normalize(vim.uv.fs_realpath(path) or path)
  dir = vim.fs.normalize(vim.uv.fs_realpath(dir) or dir)
  return path == dir or path:sub(1, #dir + 1) == dir .. "/"
end

local function root_dir(bufnr, on_dir)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local nvim_config = filename ~= "" and vim.fs.root(filename, { "lazy-lock.json" })

  if nvim_config and is_in_dir(filename, nvim_config) and is_in_dir(nvim_config, vim.fn.stdpath("config")) then
    on_dir(nvim_config)
    return
  end

  local root = vim.fs.root(bufnr, { ".luarc.json", ".luarc.jsonc", ".git" })
  if root then
    on_dir(root)
  end
end

return {
  root_dir = root_dir,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "Snacks" },
      },
      workspace = {
        checkThirdParty = false,
        ignoreDir = {
          ".git",
          ".opencode",
          ".tmp",
          "shell/.local/bin",
          "shell/.local/share",
          "shell/.local/state",
        },
      },
    },
  },
}
