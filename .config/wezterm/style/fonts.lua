local wezterm = require("wezterm")
local M = {}

function M.apply(config)
	config.font_size = 12.0
	config.freetype_load_flags = "NO_HINTING"
	config.cell_widths = {
		{ first = 0x2460, last = 0x2473, width = 1 }, -- ① .. ⑳
		{ first = 0x24EA, last = 0x24EA, width = 1 }, -- ⓪
		-- { first = 0x2668, last = 0x2668, width = 2 }, -- ♨
		-- { first = 0xF113, last = 0xF113, width = 2 }, -- 
	}
	config.font = wezterm.font_with_fallback({
		"Maple Mono",
		{ family = "LXGW WenKai", scale = 1.05 },
		-- { family = "PingFang SC", scale = 1.05 },
		-- { family = "Microsoft YaHei", scale = 1.05 },
		"Symbols Nerd Font",
		"Noto Color Emoji",
		-- "Noto Emoji",
		-- "Segoe UI Emoji",
	})
	-- config.font_rules = {
	--  for Fira Code no italic
	-- {
	-- 	italic = true,
	-- 	font = wezterm.font_with_fallback({
	-- 		{ family = 'Victor Mono', style = 'Italic', },
	-- 		"LXGW WenKai",
	-- 		"Symbols Nerd Font",
	-- 	}),
	-- },
	-- }
end

return M
