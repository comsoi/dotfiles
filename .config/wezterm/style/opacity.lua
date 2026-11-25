-- Ctrl+Leader o：在“配置里的透明度”和“完全不透明”之间切换。
-- https://github.com/wez/wezterm/discussions/4044

local wezterm = require("wezterm")
local M = {}

function M.apply(config)
	wezterm.on("toggle-opacity", function(window)
		local overrides = window:get_config_overrides() or {}

		local default_window_opacity = config.window_background_opacity
		local default_text_opacity = config.text_background_opacity

		if not overrides.window_background_opacity or overrides.window_background_opacity == default_window_opacity then
			overrides.window_background_opacity = 1
			overrides.text_background_opacity = 1
		else
			overrides.window_background_opacity = default_window_opacity
			overrides.text_background_opacity = default_text_opacity
		end

		window:set_config_overrides(overrides)
	end)
end

return M
