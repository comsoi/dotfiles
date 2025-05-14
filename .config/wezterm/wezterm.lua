local wezterm = require("wezterm")
local style = require("style.init")
local config = wezterm.config_builder()

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
style.apply(config)

-- misc
config.ssh_domains = {}

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

-- platform specific settings
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	config.launch_menu = {
		{ label = "zsh", args = { "zsh" } },
		{ label = "fish", args = { "fish" } },
		{ label = "bash", args = { "bash" } },
	}
	merge_config("keymap")
	config.default_prog = { "zsh" }
	-- for fixing https://github.com/wez/wezterm/issues/5387
	config.default_gui_startup_args = { "start", "sh", "-c", "sleep 0.3; exec zsh" }
	config.window_decorations = "NONE" -- DO NOT SET IN WAYLAND!
	config.unicode_version = 14
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
	require("msvc").apply(config)
else
	config.term = "xterm-256color"
end

if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then
	config.enable_wayland = false
	config.front_end = "WebGpu"
end

return config
