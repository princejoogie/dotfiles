local indent = require("indent_blankline")

vim.opt.list = true

indent.setup(
  {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true
  }
)
