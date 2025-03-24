return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      no_italic = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        notify = true,
        harpoon = true,
        flash = true,
        snacks = { enabled = true },
      },
    },
    init = function()
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  },
  {
    "folke/tokyonight.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        plugins = { all = true },
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = {},
          variables = {},
        },
      })
    end,
  },
}
