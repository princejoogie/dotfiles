vim.g.mapleader = " "

require("lazy").setup("joogie.plugins", { ui = { border = "rounded" } })
require("joogie.keymaps")
require("joogie.options")
