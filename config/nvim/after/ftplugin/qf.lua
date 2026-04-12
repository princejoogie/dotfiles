vim.keymap.set("n", "dd", function()
  local qf_list = vim.fn.getqflist()
  local curqfidx = nil

  if #qf_list > 0 then
    curqfidx = vim.fn.line(".") - 1
    table.remove(qf_list, curqfidx + 1)
    vim.fn.setqflist(qf_list, "r")
  end

  if #qf_list > 0 then
    vim.cmd((curqfidx + 1) .. "cfirst")
    vim.cmd("copen")
  else
    vim.cmd("cclose")
  end
end, { buffer = true, desc = "Delete item from quickfix list" })

vim.keymap.set("n", "w", function()
  local qflist = vim.fn.getqflist()
  if not qflist or #qflist == 0 then
    vim.notify("No quickfix items available", vim.log.levels.WARN)
    return
  end

  local idx = vim.fn.line(".") - 1
  if idx < 0 or idx >= #qflist then
    vim.notify("No quickfix item under cursor", vim.log.levels.WARN)
    return
  end

  local current_item = qflist[idx + 1]
  if not current_item or not current_item.bufnr then
    vim.notify("Invalid quickfix item", vim.log.levels.WARN)
    return
  end

  local success, window_id = pcall(require("window-picker").pick_window)

  if not success then
    vim.notify("Window picker not available", vim.log.levels.WARN)
    return
  end

  if not window_id then
    return
  end

  local filepath = vim.fn.bufname(current_item.bufnr)

  vim.api.nvim_set_current_win(window_id)
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  vim.fn.cursor(current_item.lnum, current_item.col)
end, { buffer = true, desc = "Open item in a specific window" })
