local wezterm = require("wezterm")
local keymap_config = require("keymap")
local cmd_abbr = require("cmd_abbr")

local launch_menu = {}
local default_prog = {}

-- global env vars
local set_environment_variables_windows = {}
local set_environment_variables_linux = {}

function scheme_for_appearance(appearance)
	-- color_scheme
	-- 'Catppuccin Frappe'
	-- 'Catppuccin Latte'
	-- 'Catppuccin Mocha',
	if appearance:find("Dark") then
		return "Catppuccin Macchiato"
		-- return "Catppuccin Frappe"
	else
		return "Catppuccin Latte"
	end
end

local config = {
	check_for_updates = false,
	-- enable_wayland = false,
	front_end = "WebGpu",
	max_fps = 165,
	enable_kitty_keyboard = true,
	disable_default_key_bindings = true,
	initial_cols = 110,
	initial_rows = 35,
	audible_bell = "Disabled",
	----------------------- style ----------------------------
	default_cursor_style = "BlinkingBar",
	color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
	-- window
	-- RESIZE | MACOS_FORCE_DISABLE_SHADOW | INTEGRATED_BUTTONS | TITLE
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	window_background_opacity = 0.75,
	text_background_opacity = 1,
	adjust_window_size_when_changing_font_size = false,
	window_padding = {
		left = 0,
		right = 0,
		top = 10,
		bottom = 0,
	},
	-- Tab bar
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	show_tab_index_in_tab_bar = true,
	tab_max_width = 35, -- +7
	tab_bar_at_bottom = false,
	-- Fonts
	font_size = 12.0,
	font = wezterm.font_with_fallback({
		"Fira Code",
		{
			family = "Microsoft YaHei",
			scale = 1,
		},
		"PingFang SC",
		"Symbols Nerd Font",
		"Segoe UI Emoji",
		"Noto Emoji",
		"Noto Color Emoji",
	}),
	-- misc
	inactive_pane_hsb = {
		hue = 1.0,
		saturation = 1.0,
		brightness = 1.0,
	},
}

-- Tab bar
local COLORS = {
	leading_bg = "rgba(35, 38, 52, 1.0)",
	leading_fg = "rgba(165, 173, 206, 1.0)",
	background_inactive = "rgba(35, 38, 52, 1.0)",
	foreground_inactive = "rgba(165, 173, 206, 1.0)",
	background_active = "rgba(114, 135, 253, 1.0)",
	foreground_active = "rgba(255, 255, 255, 1.0)",
	background_hover = "rgba(140, 170, 238, 1.0)",
	foreground_hover = "rgba(65, 69, 89, 1.0)",
	new_tab_bg = "rgba(140, 170, 238, 1.0)",
	new_tab_fg = "rgba(255, 255, 255, 1.0)",
}

local function adjust_alpha(color, new_alpha)
	-- 提取原始的 r, g, b 值
	local r, g, b = color:match("rgba%((%d+),%s*(%d+),%s*(%d+),%s*[%d%.]+%)")
	-- 使用新的透明度重新格式化颜色
	return string.format("rgba(%s, %s, %s, %.2f)", r, g, b, new_alpha)
end

local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return cmd_abbr.abbreviate_title(title)
	else
		return cmd_abbr.abbreviate_title(tab_info.active_pane.title)
	end
end

-- Tab format with colors
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local leading_bg = COLORS.leading_bg
	local leading_fg = COLORS.leading_fg
	local background = COLORS.background_inactive
	local foreground = COLORS.foreground_inactive

	if tab.is_active then
		background = COLORS.background_active
		foreground = COLORS.foreground_active
	elseif hover then
		background = COLORS.background_hover
		foreground = COLORS.foreground_hover
	end
	local text_right_arrow_fg = adjust_alpha(background, 0.75)
	local text_right_arrow_bg = adjust_alpha(leading_bg, 1)
	local text_left_arrow_fg = adjust_alpha(leading_bg, 0.75)
	local text_left_arrow_bg = adjust_alpha(background, 1)
	local title = tab_title(tab)
	-- local pane = tab.active_pane
	-- title = pane.pane_index
	-- 确保标题适合可用空间，并保留边缘显示的空间
	local index = ""

	if #tabs > 1 then
		index = string.format("%d ", tab.tab_index + 1)
	end

	return {
		{ Attribute = { Italic = false } },
		{ Attribute = { Intensity = hover and "Bold" or "Normal" } },
		{ Background = { Color = leading_bg } },
		{ Foreground = { Color = leading_fg } },

		{ Background = { Color = text_left_arrow_bg } },
		{ Foreground = { Color = text_left_arrow_fg } },
		{ Text = SOLID_RIGHT_ARROW },

		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. index .. title .. " " },

		{ Background = { Color = text_right_arrow_bg } },
		{ Foreground = { Color = text_right_arrow_fg } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

config.colors = {
	tab_bar = {
		-- text_background_opacity = 1.0,
		-- background = 'rgba(0, 0, 0, 0.0)',
	},
}

config.window_frame = {
	font_size = 8.0,
}

config.tab_bar_style = {
	new_tab = wezterm.format({
		{ Background = { Color = COLORS.new_tab_bg } },
		{ Foreground = { Color = COLORS.leading_bg } },
		{ Text = SOLID_RIGHT_ARROW },
		{ Background = { Color = COLORS.new_tab_bg } },
		{ Foreground = { Color = COLORS.new_tab_fg } },
		{ Text = " + " },
		{ Background = { Color = COLORS.leading_bg } },
		{ Foreground = { Color = COLORS.new_tab_bg } },
		{ Text = SOLID_RIGHT_ARROW },
	}),
	new_tab_hover = wezterm.format({
		{ Attribute = { Italic = false } },
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = COLORS.leading_bg } },
		{ Foreground = { Color = COLORS.leading_bg } },
		{ Text = SOLID_RIGHT_ARROW },
		{ Background = { Color = COLORS.leading_bg } },
		{ Foreground = { Color = COLORS.foreground_inactive } },
		{ Text = " + " },
		{ Background = { Color = COLORS.leading_bg } },
		{ Foreground = { Color = COLORS.leading_bg } },
		{ Text = SOLID_RIGHT_ARROW },
	}),
}

-- Scrollbar hidden
-- https://github.com/wez/wezterm/issues/4331
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.colors then
		overrides.colors = {}
	end
	if pane:is_alt_screen_active() then
		overrides.colors.scrollbar_thumb = "transparent"
		overrides.enable_scroll_bar = false
	else
		overrides.colors.scrollbar_thumb = nil
		overrides.enable_scroll_bar = true
	end
	window:set_config_overrides(overrides)
end)

-- platform specific settings
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	config.term = "wezterm"
	table.insert(launch_menu, { label = "bash", args = { "bash" } })
	table.insert(launch_menu, { label = "fish", args = { "fish" } })
	table.insert(launch_menu, { label = "zsh", args = { "zsh" } })
	config.default_prog = { "zsh" }
	config.set_environment_variables = set_environment_variables_linux
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
	table.insert(launch_menu, {
		label = "Zsh",
		args = {"D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l"}
	})
	table.insert(launch_menu, {
		label = "PowerShell",
		args = {"pwsh.exe", "-NoLogo"}
	})
	table.insert(launch_menu, {
		label = "Devuan",
		args = {"wsl.exe", "-d", "Devuan"}
	})
	table.insert(launch_menu, {
		label = "ArchWSL",
		args = {"wsl.exe", "-d", "ArchWSL", "-e", "zsh"}
	})
	table.insert(launch_menu, {
		label = "MSYS2",
		args = {"D:/Scoop/apps/msys2/current/msys2_shell.cmd", "-defterm", "-no-start", "-use-full-path", "-here", "-msys", "-shell", "fish"}
	})
	table.insert(launch_menu, {
		label = "MSYS2/UCRT64",
		args = {"D:/Scoop/apps/msys2/current/msys2_shell.cmd", "-defterm", "-no-start", "-here", "-ucrt64", "-shell", "zsh"}
	})
	table.insert(launch_menu, {
		label = "cmder",
		args = {"cmd.exe", "/k", "title Cmder/Cmd & ", "%CMDER_ROOT%\\vendor\\init.bat"}
	})
	table.insert(launch_menu, {
		label = "Fedora",
		args = {"wsl.exe", "-d", "fedoraremix", "-e", "zsh"}
	})
	table.insert(launch_menu, {
		label = "Mint21",
		args = {"wsl.exe", "-d", "Mint21", "-e", "zsh"}
	})
	table.insert(launch_menu, {
		label = "nushell",
		args = {"D:/Scoop/apps/nu/current/nu.exe"}
	})
	-- Find installed visual studio version(s) and add their compilation
	-- environment command prompts to the menu
	for _, vsvers in
		ipairs(
		wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files')
		)
	do
		local year = vsvers:gsub('Microsoft Visual Studio/', '')
		table.insert(launch_menu, {
			label = 'Developer Command Prompt for VS ' .. year,
			args = {'cmd.exe', '/k', 'C:/Program Files/' .. vsvers .. '/Community/Common7/Tools/VsDevCmd.bat',
					'-arch=x64',
					'-host_arch=x64',
					'&',
					'%CMDER_ROOT%\\vendor\\init.bat'}
		})
		table.insert(launch_menu, {
			label = 'Developer Pwsh for VS ' .. year,
			args = {'pwsh.exe', '-noe', '-c',
					'&{Import-Module "C:/Program Files/' .. vsvers .. '/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell f14d0f99}'}
})
end
	config.term = "xterm-256color"
	config.color_scheme = "Catppuccin Macchiato"
	config.default_prog = { "D:/Scoop/apps/nu/current/nu.exe" }
	config.set_environment_variables = set_environment_variables_windows
	config.hide_tab_bar_if_only_one_tab = false
	config.window_background_opacity = 0.9
	config.win32_system_backdrop = 'Acrylic'
	-- config.win32_system_backdrop = 'Mica'
	-- config.win32_system_backdrop = 'Tabbed'
	-- config.background = {
	--     {
	--         source = {
	--             File = "D:\\bg\\abg\\(pid-56669634)博麗霊夢_p0.png",
	--         },
	--         opacity = 0.33,
	--     }
	-- }
end

-- Multiplexing
config.exec_domains = {
	wezterm.exec_domain("scoped", function(cmd)
		-- The "cmd" parameter is a SpawnCommand object.
		-- You can log it to see what's inside:
		wezterm.log_info(cmd)

		-- Synthesize a human understandable scope name that is
		-- (reasonably) unique. WEZTERM_PANE is the pane id that
		-- will be used for the newly spawned pane.
		-- WEZTERM_UNIX_SOCKET is associated with the wezterm
		-- process id.
		local env = cmd.set_environment_variables
		local ident = "wezterm-pane-" .. env.WEZTERM_PANE .. "-on-" .. basename(env.WEZTERM_UNIX_SOCKET)
		-- Generate a new argument array that will launch a
		-- program via systemd-run
		local wrapped = {
			"/usr/bin/systemd-run",
			"--user",
			"--scope",
			"--description=Shell started by wezterm",
			"--same-dir",
			"--collect",
			"--unit=" .. ident,
		}

		-- Append the requested command
		-- Note that cmd.args may be nil; that indicates that the
		-- default program should be used. Here we're using the
		-- shell defined by the SHELL environment variable.
		for _, arg in ipairs(cmd.args or { os.getenv("SHELL") }) do
			table.insert(wrapped, arg)
		end

		-- replace the requested argument array with our new one
		cmd.args = wrapped

		-- and return the SpawnCommand that we want to execute
		return cmd
	end),
}

config.ssh_domains = {}
config.leader = keymap_config.leader
config.key_tables = keymap_config.key_tables
config.keys = keymap_config.keys
config.mouse_bindings = keymap_config.mouse_bindings
config.launch_menu = launch_menu

return config
