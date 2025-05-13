local wezterm = require("wezterm")

local config = wezterm.config_builder()
-- local style = require("style")

local function merge_config(module)
	local mod_config = require(module)
	for key, value in pairs(mod_config) do
		if config[key] ~= nil and type(config[key]) == "table" and type(value) == "table" then
			for _, v in ipairs(value) do
				table.insert(config[key], v)
			end
		else
			config[key] = value
		end
	end
end

merge_config("style")

config.check_for_updates = false
config.term = "wezterm"
config.default_prog = { "bash" }
config.max_fps = 165
config.enable_kitty_keyboard = true
config.disable_default_key_bindings = true
config.initial_cols = 120
config.initial_rows = 35
config.scrollback_lines = 9000
config.audible_bell = "Disabled"
-- Fonts
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
-- misc
config.ssh_domains = {}
-- config.leader = keymap_config.leader
-- config.key_tables = keymap_config.key_tables
-- config.keys = keymap_config.keys
-- config.mouse_bindings = keymap_config.mouse_bindings

-- platform specific settings
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	config.launch_menu = {
		{ label = "zsh", args = { "zsh" } },
		{ label = "fish", args = { "fish" } },
		{ label = "bash", args = { "bash" } },
	}
	merge_config("keymap")
	-- for fixing https://github.com/wez/wezterm/issues/5387
	config.default_prog = { "zsh" }
	config.default_gui_startup_args = { "start", "sh", "-c", "exec zsh" }
	config.window_decorations = "NONE" -- DO NOT SET IN WAYLAND!
	config.unicode_version = 14
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
	local msvc = require("msvc")
	msvc.apply(config)
else
	config.term = "xterm-256color"
end

if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then
	config.enable_wayland = false
	config.front_end = "WebGpu"
end

return config
