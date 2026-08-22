vim.keymap.set("n", "cc", function()
  vim.cmd("G commit")

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)

  vim.api.nvim_win_set_config(vim.api.nvim_get_current_win(), {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Commit ",
    title_pos = "center",
  })

  vim.cmd("startinsert")
end, { buffer = true, desc = "Commit changes" })
