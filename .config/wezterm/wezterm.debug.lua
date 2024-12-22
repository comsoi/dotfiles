local wezterm = require("wezterm")

local config = {}

config.check_for_updates = false
config.max_fps = 165
config.enable_csi_u_key_encoding = true
config.disable_default_key_bindings = true
config.audible_bell = "Disabled"
config.font_size = 12.0
config.freetype_load_flags = "NO_HINTING"

-- platform specific settings
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	config.term = "wezterm"
	config.default_prog = { "zsh" }
	config.window_decorations = "NONE"
	config.unicode_version = 14
end

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
	if gpu.backend == "Vulkan" and gpu.device_type == "IntegratedGpu" then
		config.webgpu_preferred_adapter = gpu
		config.front_end = "WebGpu"
		break
	end
end

return config
