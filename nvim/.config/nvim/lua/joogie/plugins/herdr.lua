if vim.env.HERDR_ENV ~= "1" or not vim.env.HERDR_PANE_ID then
  return {}
end

local function herdr_pane(action, direction)
  vim.system({
    vim.env.HERDR_BIN_PATH or "herdr",
    "pane",
    action,
    "--direction",
    direction,
    "--pane",
    vim.env.HERDR_PANE_ID,
  })
end

local function navigate(key, direction)
  local current_window = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. key)

  if vim.api.nvim_get_current_win() == current_window then
    herdr_pane("focus", direction)
  end
end

local function resize(direction)
  local step = 5
  local horizontal = direction == "left" or direction == "right"
  local near_edge = horizontal and "h" or "k"
  local far_edge = horizontal and "l" or "j"

  if vim.api.nvim_win_get_config(0).relative ~= ""
    or vim.fn.winnr("1" .. near_edge) == vim.fn.winnr("1" .. far_edge)
  then
    herdr_pane("resize", direction)
    return
  end

  local at_far_edge = vim.fn.winnr() == vim.fn.winnr("1" .. far_edge)
  if horizontal then
    if at_far_edge then
      vim.cmd("vertical resize " .. (direction == "left" and "+" or "-") .. step)
    else
      vim.fn.win_move_separator(0, direction == "left" and -step or step)
    end
  elseif at_far_edge then
    vim.cmd("resize " .. (direction == "up" and "+" or "-") .. step)
  else
    vim.fn.win_move_statusline(0, direction == "up" and -step or step)
  end
end

vim.keymap.set("n", "<C-h>", function() navigate("h", "left") end, { desc = "Move to left pane" })
vim.keymap.set("n", "<C-j>", function() navigate("j", "down") end, { desc = "Move to bottom pane" })
vim.keymap.set("n", "<C-k>", function() navigate("k", "up") end, { desc = "Move to top pane" })
vim.keymap.set("n", "<C-l>", function() navigate("l", "right") end, { desc = "Move to right pane" })

vim.keymap.set("n", "<C-Left>", function() resize("left") end, { desc = "Resize pane left" })
vim.keymap.set("n", "<C-Down>", function() resize("down") end, { desc = "Resize pane down" })
vim.keymap.set("n", "<C-Up>", function() resize("up") end, { desc = "Resize pane up" })
vim.keymap.set("n", "<C-Right>", function() resize("right") end, { desc = "Resize pane right" })

return {}
