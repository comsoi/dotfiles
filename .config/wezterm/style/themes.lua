local wezterm = require("wezterm")
local M = {}

local light_theme = nil
local dark_theme = nil

function M.scheme_for_appearance(appearance, config, force)
	force = force or false
	-- force = true
	-- color_scheme
	-- t = "Catppuccin Frappe"
	-- t = "Catppuccin Latte"
	-- t = "Catppuccin Mocha"
	-- t = "Catppuccin Macchiato"
	-- t = "Tokyo Night Day"
	-- t = "Tokyo Night Light (Gogh)"
	-- t = "Horizon Bright (Gogh)"
	-- t = "Brush Trees (base16)"

	if force then
		local t = ""
		return t
	end

	if appearance:find("Light") then
		light_theme = "Tokyo Night Day"
		config.text_min_contrast_ratio = 1.7
		return light_theme
	end

	dark_theme = "Catppuccin Macchiato"
	return dark_theme
end

function M.apply(config)
	local appearance = wezterm.gui.get_appearance()
	config.color_scheme = M.scheme_for_appearance(appearance, config)
end

return M
