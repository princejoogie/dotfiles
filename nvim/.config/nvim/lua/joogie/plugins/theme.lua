return {
  {
    "catppuccin/nvim",
    enabled = true,
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = not vim.uv.os_uname().sysname == "Darwin",
      no_italic = true,
      integrations = {
        harpoon = true,
        snacks = { enabled = true, indent_scope_color = "surface2" },
      },
      custom_highlights = function(colors)
        return {
          Folded = { fg = colors.overlay2, bg = colors.base },
          NesDelete = { cterm = { strikethrough = true }, strikethrough = true, bg = "#443245" },
        }
      end,
    },
    init = function()
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  },
}
