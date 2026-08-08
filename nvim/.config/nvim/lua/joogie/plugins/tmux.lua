local cmd = require("joogie.utils").cmd

return {
  "aserowy/tmux.nvim",
  cond = vim.env.TMUX ~= nil and vim.env.HERDR_ENV ~= "1",
  lazy = false,
  opts = {
    copy_sync = { enable = false },
    resize = { resize_step_x = 5, resize_step_y = 5 },
  },
  -- stylua: ignore
  keys = {
    { "<C-Left>",  cmd("lua require('tmux').resize_left()"),   desc = "+ Resize Vertically" },
    { "<C-Down>",  cmd("lua require('tmux').resize_bottom()"), desc = "+ Resize Horizontally" },
    { "<C-Up>",    cmd("lua require('tmux').resize_top()"),    desc = "- Resize Horizontally" },
    { "<C-Right>", cmd("lua require('tmux').resize_right()"),  desc = "- Resize Vertically" },
    { "<C-h>",     cmd("lua require('tmux').move_left()"),     desc = "Move to left pane" },
    { "<C-j>",     cmd("lua require('tmux').move_bottom()"),   desc = "Move to bottom pane" },
    { "<C-k>",     cmd("lua require('tmux').move_top()"),      desc = "Move to top pane" },
    { "<C-l>",     cmd("lua require('tmux').move_right()"),    desc = "Move to right pane" },
  },
}
