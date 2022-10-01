local function get(setting, default)
  local key = "tokyodark_" .. setting
  if vim.g[key] == nil then
    return default
  end
  return vim.g[key]
end

local config = {
  bg = get("transparent_background", false),
  italic = get("enable_italic", false),
  italic_comment = get("enable_italic_comment", false),
  gamma = get("color_gamma", "1.0")
}

return config
