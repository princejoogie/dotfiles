vim.g.mapleader = " "

require("joogie.autocmds")
require("joogie.options")
---@diagnostic disable-next-line: missing-fields
require("lazy").setup("joogie.plugins", { ui = { border = "rounded" }, })
require("joogie.keymaps")
