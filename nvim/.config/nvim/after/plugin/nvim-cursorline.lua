local status, cursor = pcall(require, "nvim-cursorline")
if (not status) then return end

cursor.setup {
  cursorline = {
    enable = false,
    timeout = 500,
    number = false
  },
  cursorword = {
    enable = true,
    min_length = 3,
    -- hl = {underline = true}
    hl = {bold= true, underline = false}
  }
}
