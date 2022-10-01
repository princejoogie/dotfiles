local color_gamma = require("nabi.utils").color_gamma
local gamma = require("nabi.config").gamma

local colors = {
	black = "#06080A",
	white = "#FFFFFF",
	bg0 = "#11121D",
	bg1 = "#1A1B2A",
	bg2 = "#212234",
	bg3 = "#353945",
	bg4 = "#4B5563",
	bg5 = "#282c34",
	bg_red = "#FE6D85",
	bg_green = "#98C379",
	bg_blue = "#9FBBF3",
	diff_red = "#773440",
	diff_green = "#587738",
	diff_blue = "#354A77",
	diff_add = "#1E2326",
	diff_change = "#262b3d",
	diff_delete = "#281B27",
	fg = "#A0A8CD",
	red = "#EE6D85",
	orange = "#F6955B",
	yellow = "#D7A65F",
	green = "#95C561",
	blue = "#7199EE",
	cyan = "#38A89D",
	purple = "#A485DD",
	grey = "#4A5057",
	magenta = "#C678DD",
	violet = "#A9A1E1",
	none = "NONE",
	warning = "#F6955B",
	info = "#D7A65F",
}

local function gamma_correction(c)
	local colors_corrected = {}
	for k, v in pairs(c) do
		colors_corrected[k] = color_gamma(v, gamma)
	end
	return colors_corrected
end

return gamma_correction(colors)
