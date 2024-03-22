vim.g.mapleader = " "

require("joogie.autocmds")
require("joogie.options")
require("lazy").setup("joogie.plugins", { ui = { border = "rounded" } })
require("joogie.keymaps")
