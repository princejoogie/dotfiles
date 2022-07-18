require("nvim-tree").setup(
  {
    view = {width = 40},
    update_focused_file = {
      enable = true,
      update_cwd = false,
      ignore_list = {}
    },
    renderer = {
      highlight_opened_files = "current"
    }
  }
)
