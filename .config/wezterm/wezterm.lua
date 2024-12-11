local wezterm                           = require("wezterm")
local keymap_config                     = require("keymap")
local cmd_abbr                          = require("cmd_abbr")

local default_prog                      = { "bash" }
local launch_menu                       = {}
local set_environment_variables_linux   = {}
local set_environment_variables_windows = {}

local function scheme_for_appearance(appearance)
	-- color_scheme
	-- 'Catppuccin Frappe'
	-- 'Catppuccin Latte'
	-- 'Catppuccin Mocha',
	if appearance:find("Dark") then
		return "Catppuccin Macchiato"
	elseif appearance:find("Light") then
		return "Catppuccin Latte"
	else
		return "Catppuccin Macchiato"
	end
end

local config = {
	check_for_updates = false,
	--	enable_wayland = false,
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
	tab_max_width = 36, -- +8
	tab_bar_at_bottom = true,
	-- Fonts
	font_size = 14.0,
	freetype_load_flags = 'NO_HINTING',
	font = wezterm.font_with_fallback({
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
	}),
	-- misc
	inactive_pane_hsb = {
		hue = 1.0,
		saturation = 1.0,
		brightness = 0.8,
	},
}

config.font_rules = {
	--  for Fira Code no italic
	-- {
	-- 	italic = true,
	-- 	font = wezterm.font_with_fallback({
	-- 		{ family = 'Victor Mono', style = 'Italic', },
	-- 		"LXGW WenKai",
	-- 		"Symbols Nerd Font",
	-- 	}),
	-- },
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

-- https://github.com/wez/wezterm/discussions/4044
wezterm.on("toggle-opacity", function(window, pane)
	wezterm.log_info("toggling the leader")
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		-- if no override is setup, override the default opacity value with 1.0
		overrides.window_background_opacity = 1
	else
		if overrides.window_background_opacity == 0.75 then
			overrides.window_background_opacity = 1
		elseif overrides.window_background_opacity == 1 then
			overrides.window_background_opacity = 0.75
		end
	end
	window:set_config_overrides(overrides)
end)

-- Tab format with colors
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local leading_bg = COLORS.leading_bg
	local leading_fg = COLORS.leading_fg
	local background = COLORS.background_inactive
	local foreground = COLORS.foreground_inactive
	local zoomed = ""
	if tab.is_active then
		background = COLORS.background_active
		foreground = COLORS.foreground_active
	elseif hover then
		background = COLORS.background_hover
		foreground = COLORS.foreground_hover
	end
	if tab.active_pane.is_zoomed then
		zoomed = '+'
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
		{ Text = " " .. index .. title .. " " .. zoomed .. " " },

		{ Background = { Color = text_right_arrow_bg } },
		{ Foreground = { Color = text_right_arrow_fg } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

config.colors = {
	compose_cursor = 'orange',
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
	-- right status
	local date = wezterm.strftime '%a %b %-d %H:%M '

	local bat = ''
	local leader = ''
	for _, b in ipairs(wezterm.battery_info()) do
		bat = '🔋 ' .. string.format('%.0f%%', b.state_of_charge * 100)
	end
	if window:leader_is_active() then
		leader = 'LEADER'
		-- 	overrides.colors.tab_bar = {
		-- 		background = 'orange',
		-- 	}
		-- else
		-- 	overrides.colors.tab_bar = {
		-- 		background = COLORS.background_hover,
		-- 	}
	end
	window:set_right_status(wezterm.format {
		{ Text = leader .. '   ' .. bat .. '   ' .. date },
	})
end)

-- platform specific settings
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	config.term = "wezterm"
	table.insert(launch_menu, { label = "bash", args = { "bash" } })
	table.insert(launch_menu, { label = "fish", args = { "fish" } })
	table.insert(launch_menu, { label = "zsh", args = { "zsh" } })
	-- for fixing https://github.com/wez/wezterm/issues/5387
	config.default_prog = { "sh", "-c", "sleep 0.3; exec zsh" }
	config.window_decorations = "NONE" -- DO NOT SET IN WAYLAND!
	config.set_environment_variables = set_environment_variables_linux
	config.unicode_version = 14
else
	config.term = "xterm-256color"
	-- config.set_environment_variables = set_environment_variables_windows
	-- config.win32_system_backdrop = 'Acrylic'
	-- config.win32_system_backdrop = 'Mica'
	-- config.win32_system_backdrop = 'Tabbed'
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

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
	if gpu.backend == 'Vulkan' and gpu.device_type == 'IntegratedGpu' then
		config.webgpu_preferred_adapter = gpu
		config.front_end = 'WebGpu'
		break
	end
end

config.ssh_domains = {}
config.leader = keymap_config.leader
config.key_tables = keymap_config.key_tables
config.keys = keymap_config.keys
config.mouse_bindings = keymap_config.mouse_bindings
config.launch_menu = launch_menu

return config
