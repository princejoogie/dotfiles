local alpha = safe_require("alpha")

if not alpha then
  return
end

local dashboard = safe_require("alpha.themes.dashboard")

if not dashboard then
  return
end

local M = {}

M.setup = function()
  dashboard.section.header.val = {
    [[                                                ]],
    [[                                                ]],
    [[                                                ]],
    [[                                                ]],
    [[      ██╗ ██████╗  ██████╗  ██████╗ ██╗███████╗ ]],
    [[      ██║██╔═══██╗██╔═══██╗██╔════╝ ██║██╔════╝ ]],
    [[      ██║██║   ██║██║   ██║██║  ███╗██║█████╗   ]],
    [[ ██   ██║██║   ██║██║   ██║██║   ██║██║██╔══╝   ]],
    [[ ╚█████╔╝╚██████╔╝╚██████╔╝╚██████╔╝██║███████╗ ]],
    [[  ╚════╝  ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝╚══════╝ ]],
    [[                                                ]],
  }

  dashboard.section.buttons.val = {
    dashboard.button(
      "f",
      "  Find file",
      "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>"
    ),
    dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
    dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
    dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
    dashboard.button("q", "  Quit Neovim", ":qa<CR>")
  }

  local function footer()
    return "“Should've named my kids tech debt, they're never going away.” – Trash"
  end

  dashboard.section.footer.val = footer()

  dashboard.section.footer.opts.hl = "Type"
  dashboard.section.header.opts.hl = "Include"
  dashboard.section.buttons.opts.hl = "Keyword"

  dashboard.opts.opts.noautocmd = true
  alpha.setup(dashboard.opts)
end

return M
