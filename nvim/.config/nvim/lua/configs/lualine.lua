---@diagnostic disable: duplicate-index
local lualine = safe_require("lualine")
local package = safe_require("package-info")

if not (lualine and package) then
	return
end

local icons = require("utils").icons
local p = require("nabi.palette")

local M = {}

M.setup = function()
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
		end,
	}

	-- Config
	local config = {
		options = {
			-- Disable sections and component separators
			component_separators = "",
			section_separators = "",
			theme = {
				normal = { c = { fg = p.fg, bg = p.bg1 } },
				inactive = { c = { fg = p.fg, bg = p.bg1 } },
			},
		},
		sections = {
			-- these are to remove the defaults
			lualine_a = {},
			lualine_b = {},
			lualine_y = {},
			lualine_z = {},
			-- These will be filled later
			lualine_c = {},
			lualine_x = {},
		},
		inactive_sections = {
			-- these are to remove the defaults
			lualine_a = {},
			lualine_b = {},
			lualine_y = {},
			lualine_z = {},
			lualine_c = {},
			lualine_x = {},
		},
	}

	-- Inserts a component in lualine_c at left section
	local function ins_left(component)
		table.insert(config.sections.lualine_c, component)
	end

	-- Inserts a component in lualine_x ot right section
	local function ins_right(component)
		table.insert(config.sections.lualine_x, component)
	end

	ins_left({
		"branch",
		icon = "",
		color = { fg = p.green },
	})

	ins_left({
		"filename",
		cond = conditions.buffer_not_empty,
		color = { fg = p.magenta },
	})

	ins_left({
		"diff",
		diff_color = {
			added = { fg = p.green },
			modified = { fg = p.orange },
			removed = { fg = p.red },
		},
		cond = conditions.hide_in_width,
	})

	ins_left({
		"diagnostics",
		sources = { "nvim_diagnostic" },
		symbols = { error = icons.Error, warn = icons.Warn, hint = icons.Hint, info = icons.Info },
		diagnostics_color = {
			color_error = { fg = p.red },
			color_warn = { fg = p.yellow },
			color_info = { fg = p.cyan },
		},
	})

	ins_left({
		"lsp_progress",
		display_components = { "spinner", { "title", "progress", "message" } },
		timer = { progress_enddelay = 500, spinner = 500, lsp_client_name_enddelay = 1000 },
		spinner_symbols = icons.Spinner,
	})

	ins_right({
		function()
			return package.get_status()
		end,
		color = { fg = p.green },
	})

	ins_right({
		"filetype",
		color = { fg = p.green },
	})

	ins_right({
		"o:encoding",
		cond = conditions.hide_in_width,
		color = { fg = p.green },
	})

	ins_right({
		"fileformat",
		icons_enabled = false,
		color = { fg = p.green },
	})

	ins_right({
		"mode",
		color = { fg = p.magenta },
	})

	lualine.setup(config)
end

return M
