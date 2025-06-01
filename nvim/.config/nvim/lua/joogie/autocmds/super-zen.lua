local is_super_zen = false

local function super_zen_toggle()
  if not is_super_zen then
    vim.opt.laststatus = 0
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.cmd("lua Snacks.indent.disable()")
    os.execute("tmux set status off")
    is_super_zen = true
  else
    vim.opt.laststatus = 2
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.cmd("lua Snacks.indent.enable()")
    os.execute("tmux set status on")
    is_super_zen = false
  end

  vim.cmd("TSContextToggle")
end

vim.api.nvim_create_user_command("SuperZenToggle", super_zen_toggle, {
  nargs = 0,
  desc = "Enable super zen mode",
})

vim.keymap.set("n", "<leader>sm", "<cmd>SuperZenToggle<cr>", { desc = "Toggle super zen mode" })
