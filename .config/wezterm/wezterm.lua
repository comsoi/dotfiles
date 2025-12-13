local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("style.init").apply(config)
require("keybindings.init").apply(config)

config.check_for_updates = false
config.term = "wezterm"
config.max_fps = 165
config.animation_fps = 240
config.initial_cols = 120
config.initial_rows = 35
config.scrollback_lines = 9000
config.audible_bell = "Disabled"

config.ssh_domains = {}

if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	config.launch_menu = {
		{ label = "zsh",  args = { "zsh"  } },
		{ label = "fish", args = { "fish" } },
		{ label = "bash", args = { "bash" } },
		{ label = "tmux", args = { "tmux" } },
	}
	config.default_prog = { "zsh" }
	config.default_gui_startup_args = { "start", "sh", "-c", "sleep 0.3; exec zsh" }
	config.window_decorations = "NONE" -- DO NOT SET IN WAYLAND!
	config.unicode_version = 14
	-- if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then
	-- 	config.dpi = 384
	-- end
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
	require("msvc").apply(config)
end

return config
