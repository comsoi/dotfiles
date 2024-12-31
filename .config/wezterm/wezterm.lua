local wezterm = require("wezterm")

local config = wezterm.config_builder()
local launch_menu = {}
local set_environment_variables_linux = {}
local set_environment_variables_windows = {}

local function merge_config(module)
	local mod_config = require(module)
	for key, value in pairs(mod_config) do
		config[key] = value
	end
end

merge_config("style")
merge_config("keymap")

config.check_for_updates = false
config.term = "wezterm"
config.default_prog = { "bash" }
-- config.enable_wayland = false,
config.max_fps = 165
config.log_unknown_escape_sequences = true
config.enable_kitty_keyboard = true
-- config.enable_csi_u_key_encoding = true
config.disable_default_key_bindings = true
config.initial_cols = 120
config.initial_rows = 35
config.audible_bell = "Disabled"
-- Fonts
config.font_size = 12.0
config.freetype_load_flags = "NO_HINTING"
-- config.treat_east_asian_ambiguous_width_as_wide = true
config.font = wezterm.font_with_fallback({
	"Maple Mono",
	-- "MonaspiceNe Nerd Font",
	{ family = "LXGW WenKai", scale = 1.05 },
	-- { family = "PingFang SC", scale = 1.05 },
	-- { family = "Microsoft YaHei", scale = 1.05 },
	"Sarasa Term J",
	"Symbols Nerd Font",
	"Noto Color Emoji",
	-- "Noto Emoji",
	"Segoe UI Emoji",
})
-- misc
config.inactive_pane_hsb = {
	hue = 1.0,
	saturation = 1.0,
	brightness = 0.8,
}
config.ssh_domains = {}
-- config.leader = keymap_config.leader
-- config.key_tables = keymap_config.key_tables
-- config.keys = keymap_config.keys
-- config.mouse_bindings = keymap_config.mouse_bindings
config.launch_menu = launch_menu

-- platform specific settings
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	config.term = "wezterm"
	table.insert(launch_menu, { label = "bash", args = { "bash" } })
	table.insert(launch_menu, { label = "fish", args = { "fish" } })
	table.insert(launch_menu, { label = "zsh", args = { "zsh" } })
	-- for fixing https://github.com/wez/wezterm/issues/5387
	config.default_prog = { "zsh" }
	config.default_gui_startup_args = { "start", "sh", "-c", "sleep 0.3; exec zsh" }
	config.window_decorations = "NONE" -- DO NOT SET IN WAYLAND!
	config.set_environment_variables = set_environment_variables_linux
	config.unicode_version = 14
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
	local wsl_domains = wezterm.default_wsl_domains()
	for idx = #wsl_domains, 1, -1 do
		if wsl_domains[idx].name == 'WSL:docker-desktop-data'
			or wsl_domains[idx].name == 'WSL:docker-desktop' then
			table.remove(wsl_domains, idx) -- 删除该元素
		end
	end
	config.wsl_domains = wsl_domains
	config.default_prog = { "wsl.exe", "-d", "Devuan" }
	table.insert(launch_menu, {
		label = "Zsh",
		args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" }
	})
	table.insert(launch_menu, {
		label = "PowerShell",
		args = { "pwsh.exe", "-NoLogo" }
	})
	table.insert(launch_menu, {
		label = "MSYS2",
		args = { "D:/Scoop/apps/msys2/current/msys2_shell.cmd", "-defterm", "-no-start", "-use-full-path", "-here", "-msys", "-shell", "fish" }
	})
	table.insert(launch_menu, {
		label = "MSYS2/UCRT64",
		args = { "D:/Scoop/apps/msys2/current/msys2_shell.cmd", "-defterm", "-no-start", "-here", "-ucrt64", "-shell", "zsh" }
	})
	table.insert(launch_menu, {
		label = "cmder",
		args = { "cmd.exe", "/k", "title Cmder/Cmd & ", "%CMDER_ROOT%\\vendor\\init.bat" }
	})
	table.insert(launch_menu, {
		label = "nushell",
		args = { "D:/Scoop/apps/nu/current/nu.exe" }
	})
	for _, vsvers in
	ipairs(
		wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files')
	)
	do
		local year = vsvers:gsub('Microsoft Visual Studio/', '')
		table.insert(launch_menu, {
			label = 'Developer Command Prompt for VS ' .. year,
			args = { 'cmd.exe', '/k', 'C:/Program Files/' .. vsvers .. '/Community/Common7/Tools/VsDevCmd.bat',
				'-arch=x64',
				'-host_arch=x64',
				'&',
				'%CMDER_ROOT%\\vendor\\init.bat' }
		})
		table.insert(launch_menu, {
			label = 'Developer Pwsh for VS ' .. year,
			args = { 'pwsh.exe', '-noe', '-c',
				'&{Import-Module "C:/Program Files/' ..
				vsvers .. '/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell f14d0f99}' }
		})
	end
	config.set_environment_variables = set_environment_variables_windows
	config.tab_bar_at_bottom = false
	config.win32_system_backdrop = 'Acrylic'
	table.insert(config.keys, { key = "Return", mods = "ALT", action = "ToggleFullScreen" })
else
	config.term = "xterm-256color"
end

-- Multiplexing
-- local function basename(s)
-- 	return string.gsub(s, "(.*[/\\])(.*)", "%2")
-- end
-- config.exec_domains = {
-- 	wezterm.exec_domain("scoped", function(cmd)
-- 		-- The "cmd" parameter is a SpawnCommand object.
-- 		-- You can log it to see what's inside:
-- 		wezterm.log_info(cmd)
--
-- 		-- Synthesize a human understandable scope name that is
-- 		-- (reasonably) unique. WEZTERM_PANE is the pane id that
-- 		-- will be used for the newly spawned pane.
-- 		-- WEZTERM_UNIX_SOCKET is associated with the wezterm
-- 		-- process id.
-- 		local env = cmd.set_environment_variables
-- 		local ident = "wezterm-pane-" .. env.WEZTERM_PANE .. "-on-" .. basename(env.WEZTERM_UNIX_SOCKET)
-- 		-- Generate a new argument array that will launch a
-- 		-- program via systemd-run
-- 		local wrapped = {
-- 			"/usr/bin/systemd-run",
-- 			"--user",
-- 			"--scope",
-- 			"--description=Shell started by wezterm",
-- 			"--same-dir",
-- 			"--collect",
-- 			"--unit=" .. ident,
-- 		}
--
-- 		-- Append the requested command
-- 		-- Note that cmd.args may be nil; that indicates that the
-- 		-- default program should be used. Here we're using the
-- 		-- shell defined by the SHELL environment variable.
-- 		for _, arg in ipairs(cmd.args or { os.getenv("SHELL") }) do
-- 			table.insert(wrapped, arg)
-- 		end
--
-- 		-- replace the requested argument array with our new one
-- 		cmd.args = wrapped
--
-- 		-- and return the SpawnCommand that we want to execute
-- 		return cmd
-- 	end),
-- }

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
	if gpu.backend == "Vulkan" and gpu.device_type == "IntegratedGpu" then
		config.webgpu_preferred_adapter = gpu
		config.front_end = "WebGpu"
		break
	end
end

return config
