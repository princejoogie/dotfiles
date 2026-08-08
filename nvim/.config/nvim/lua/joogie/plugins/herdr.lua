if vim.env.HERDR_ENV ~= "1" or not vim.env.HERDR_PANE_ID then
  return {}
end

local function navigate(key, direction)
  local current_window = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. key)

  if vim.api.nvim_get_current_win() == current_window then
    vim.system({
      "herdr",
      "pane",
      "focus",
      "--direction",
      direction,
      "--pane",
      vim.env.HERDR_PANE_ID,
    })
  end
end

vim.keymap.set("n", "<C-h>", function() navigate("h", "left") end, { desc = "Move to left pane" })
vim.keymap.set("n", "<C-j>", function() navigate("j", "down") end, { desc = "Move to bottom pane" })
vim.keymap.set("n", "<C-k>", function() navigate("k", "up") end, { desc = "Move to top pane" })
vim.keymap.set("n", "<C-l>", function() navigate("l", "right") end, { desc = "Move to right pane" })

return {}
