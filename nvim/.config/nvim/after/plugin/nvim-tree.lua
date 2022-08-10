local status, nvim_tree = pcall(require, "nvim-tree")
if (not status) then return end

nvim_tree.setup(
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
