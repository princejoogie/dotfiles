require("nvim-cursorline").setup {
  cursorline = {
    enable = false,
    timeout = 500,
    number = false
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = {underline = true}
  }
}
