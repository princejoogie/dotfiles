local M = {}

M.send_highlighted_to_opencode = function()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")

  local line_start = vstart[2]
  local line_end = vend[2]

  if line_start == 0 or line_end == 0 then
    vim.notify("No text selected 1", vim.log.levels.WARN)
    return
  end

  local lines = vim.fn.getline(line_start, line_end)

  local selected_text = table.concat(lines, "\n")

  vim.fn.setreg("+", selected_text)

  local current_session = vim.fn.system("tmux display-message -p '#S'"):gsub("\n", "")

  local panes_info = vim.fn
    .system("tmux list-panes -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}' -a")
    :gsub("\n$", "")

  local opencode_target = nil
  for line in panes_info:gmatch("[^\n]+") do
    if line:match("opencode") and line:match("^" .. current_session .. ":") then
      opencode_target = line:match("^([^%s]+)")
      break
    end
  end

  if not opencode_target then
    vim.notify("`opencode` not found in current session", vim.log.levels.WARN)
    return
  end

  vim.fn.system(string.format("tmux send-keys -t '%s' C-x e", opencode_target))

  vim.defer_fn(function()
    vim.fn.system(string.format("tmux send-keys -t '%s' p", opencode_target))

    local window_target = opencode_target:match("^([^%.]+)")
    vim.fn.system(string.format("tmux select-window -t '%s'", window_target))
    vim.fn.system(string.format("tmux select-pane -t '%s'", opencode_target))
  end, 100)
end

vim.api.nvim_create_user_command("OpencodeSend", M.send_highlighted_to_opencode, {
  nargs = 0,
  range = true,
  desc = "Send highlighted text to opencode",
})

vim.keymap.set("v", "<leader>os", ":<C-u>OpencodeSend<cr>", { desc = "Send highlighted text to opencode" })

return M
