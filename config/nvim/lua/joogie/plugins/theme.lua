return {
  {
    "catppuccin/nvim",
    enabled = true,
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = true,
      float = { transparent = true },
      no_italic = true,
      integrations = {
        harpoon = true,
        snacks = { enabled = true, indent_scope_color = "surface2" },
      },
      custom_highlights = function(colors)
        return {
          Folded = { fg = colors.overlay2, bg = "#000000" },
          NesDelete = { cterm = { strikethrough = true }, strikethrough = true, bg = "#443245" },
          DiffDelete = { fg = "#343942", bg = "#000000" },
          DiffChange = { bg = "#000000" },
          DiffAdd = { bg = "#233228" },
        }
      end,
    },
    init = function()
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  },
}
