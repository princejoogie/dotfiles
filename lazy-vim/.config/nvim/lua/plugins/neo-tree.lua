return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      { "s1n7ax/nvim-window-picker", opts = {} },
    },
    opts = {
      window = {
        mappings = {
          ["<C-b>"] = "noop",
          ["/"] = "noop",
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
        },
        hijack_netrw_behavior = "open_default",
      },
    },
  },
}
