---@diagnostic disable: duplicate-index
local lualine = require("lualine")
local package = require("package-info")

-- barbar overrides
-- set highlight BufferVisible background to #1A1B2A
-- set highlight BufferVisible foreground to #FFFFFF

local p = require("tokyodark.palette")

-- Color table for highlights
local colors = {
  bg = p.bg1,
  black = "#000000",
  blue = p.blue,
  cyan = p.cyan,
  darkblue = "#081633",
  fg = p.fg,
  green = p.green,
  grey = p.grey,
  magenta = "#c678dd",
  orange = "#FF8800",
  purple = p.purple,
  red = p.red,
  violet = "#a9a1e1",
  yellow = p.yellow
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand("%:p:h")
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end
}

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = "",
    section_separators = "",
    theme = {
      normal = {c = {fg = colors.fg, bg = colors.bg}},
      inactive = {c = {fg = colors.fg, bg = colors.bg}}
    }
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {}
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {}
  }
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

ins_left {
  "mode",
  color = function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.red,
      i = colors.green,
      v = colors.blue,
      [""] = colors.blue,
      V = colors.blue,
      c = colors.magenta,
      no = colors.red,
      s = colors.orange,
      S = colors.orange,
      [""] = colors.orange,
      ic = colors.yellow,
      R = colors.violet,
      Rv = colors.violet,
      cv = colors.red,
      ce = colors.red,
      r = colors.cyan,
      rm = colors.cyan,
      ["r?"] = colors.cyan,
      ["!"] = colors.red,
      t = colors.red
    }
    return {bg = mode_color[vim.fn.mode()], fg = colors.black}
  end
}

ins_left {
  "branch",
  icon = "",
  color = {fg = colors.green, gui = "bold"}
}

ins_left {
  "filename",
  cond = conditions.buffer_not_empty,
  color = {fg = colors.magenta, gui = "bold"}
}

ins_left {
  "diff",
  diff_color = {
    added = {fg = colors.green},
    modified = {fg = colors.orange},
    removed = {fg = colors.red}
  },
  cond = conditions.hide_in_width
}

ins_left {
  "diagnostics",
  sources = {"nvim_diagnostic"},
  symbols = {error = " ", warn = " ", hint = " ", info = " "},
  diagnostics_color = {
    color_error = {fg = colors.red},
    color_warn = {fg = colors.yellow},
    color_info = {fg = colors.cyan}
  }
}

ins_left {
  "lsp_progress",
  display_components = {"spinner", {"title", "progress", "message"}},
  timer = {progress_enddelay = 500, spinner = 100, lsp_client_name_enddelay = 1000},
  spinner_symbols = {"⣾", "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽"}
}

ins_right {
  function()
    return package.get_status()
  end,
  color = {fg = colors.green, gui = "bold"}
}

ins_right {
  "filetype",
  color = {fg = colors.green, bg = colors.bg, gui = "bold"}
}

ins_right {
  "o:encoding",
  cond = conditions.hide_in_width,
  color = {fg = colors.green, gui = "bold"}
}

ins_right {
  "fileformat",
  icons_enabled = false,
  color = {fg = colors.green, gui = "bold"}
}

ins_right {
  "filesize",
  cond = conditions.buffer_not_empty
}

ins_right {"location"}

ins_right {"progress", color = {fg = colors.fg, gui = "bold"}}

lualine.setup(config)
