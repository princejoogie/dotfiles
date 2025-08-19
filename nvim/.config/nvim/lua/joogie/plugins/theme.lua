return {
  {
    "catppuccin/nvim",
    enabled = true,
    name = "catppuccin",
    priority = 1000,
    opts = {
<<<<<<< HEAD
      transparent_background = is_transparent,
      float = {
        transparent = is_transparent
      },
||||||| parent of 379645d (fix: not a git repo message)
      transparent_background = vim.uv.os_uname().sysname == "Darwin" and false or true,
=======
      transparent_background = true,
      float = { transparent = true, },
>>>>>>> 379645d (fix: not a git repo message)
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
