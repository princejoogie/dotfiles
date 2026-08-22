local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
require("joogie.options")

require("lazy").setup({
  require("joogie.plugins.theme"),
  require("joogie.plugins.diffview"),
  require("joogie.plugins.tmux"),
  require("joogie.plugins.herdr"),
  { "tpope/vim-fugitive", cmd = { "G", "Git" } },
}, {
  change_detection = { enabled = false },
  checker = { enabled = false },
  install = { missing = false },
  ui = { border = "rounded" },
})

require("joogie.keymaps")
