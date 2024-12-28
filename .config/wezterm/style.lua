local wezterm = require("wezterm")
local cmd_abbr = require("cmd_abbr")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local config = wezterm.config_builder()
local light_theme = nil
local dark_theme = nil
local text_opacity = 1

cmd_abbr.set_max_length(20)
workspace_switcher.workspace_formatter = function(label)
	return wezterm.format({
		{ Attribute = { Italic = true } },
		{ Text = wezterm.nerdfonts.cod_terminal_tmux .. " " .. string.match(label, "[^/\\]+$") },
	})
end

local function tab_title(tab_info)
	if tab_info.active_pane.domain_name ~= "local" then
		return ""
	end
	if not tab_info.is_active then
		if #tab_info.tab_title > 0 then
			return "⌘ " .. tab_info.tab_title .. "|"
		else
			return ""
		end
	end
	local title = cmd_abbr.abbreviate_title(tab_info.active_pane.title)
	if title:sub(1, 1) == " " then
		return title:sub(2)
	end
	return title
end
-- if tab_info.tab_title and #tab_info.tab_title > 0 then
-- 	return tab_info.tab_title
-- else
-- 	local title = cmd_abbr.abbreviate_title(tab_info.active_pane.title)
-- 	if title:sub(1, 1) == " " then
-- 		return title:sub(2)
-- 	end
-- 	return title
-- end

local function leader(window)
	if window:leader_is_active() then
		return " LEADER "
	end
	return ""
end

local function scheme_for_appearance(appearance, force)
	force = force or false
	-- color_scheme
	-- t = 'Catppuccin Frappe'
	-- t = 'Catppuccin Latte'
	-- t = 'Catppuccin Mocha'
	-- t = 'Catppuccin Macchiato'
	-- t = 'Tokyo Night Day'
	-- t = 'Tokyo Night Light (Gogh)'
	-- t = 'Horizon Bright (Gogh)'
	-- t = 'Brush Trees (base16)'
	if force then
		local t = ""
		t = "Catppuccin Mocha"
		return t
	end
	if appearance:find("Light") then
		light_theme = "Tokyo Night Day"
		return light_theme
	end
	dark_theme = "Catppuccin Macchiato"
	return dark_theme
end

local auto_theme = scheme_for_appearance(wezterm.gui.get_appearance())

tabline.setup({
	options = { theme = auto_theme, tabs_enabled = true },
	sections = {
		tabline_c = { leader },
		tab_active = {
			"index",
			"⌘ ",
			{ "cwd", padding = 0 },
			{ "process" },
			tab_title,
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { tab_title, { "process", padding = { left = 0, right = 1 } } },
	},
	tabline_x = { { "cpu", throttle = 5 } },
	extensions = { "smart_workspace_switcher" },
})

-- Tab bar
-- local COLORS = {
-- 	leading_bg = "rgba(35, 38, 52, 1.0)",
-- 	leading_fg = "rgba(165, 173, 206, 1.0)",
-- 	background_inactive = "rgba(35, 38, 52, 1.0)",
-- 	foreground_inactive = "rgba(165, 173, 206, 1.0)",
-- 	background_active = "rgba(114, 135, 253, 1.0)",
-- 	foreground_active = "rgba(255, 255, 255, 1.0)",
-- 	background_hover = "rgba(140, 170, 238, 1.0)",
-- 	foreground_hover = "rgba(65, 69, 89, 1.0)",
-- 	new_tab_bg = "rgba(140, 170, 238, 1.0)",
-- 	new_tab_fg = "rgba(255, 255, 255, 1.0)",
-- }
-- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
--
-- local function adjust_alpha(color, new_alpha)
-- 	-- 提取原始的 r, g, b 值
-- 	local r, g, b = color:match("rgba%((%d+),%s*(%d+),%s*(%d+),%s*[%d%.]+%)")
-- 	-- 使用新的透明度重新格式化颜色
-- 	return string.format("rgba(%s, %s, %s, %.2f)", r, g, b, new_alpha)
-- end
--
--
-- local function tab_title(tab_info)
-- 	local title = tab_info.tab_title
-- 	if title and #title > 0 then
-- 		return cmd_abbr.abbreviate_title(title)
-- 	else
-- 		return cmd_abbr.abbreviate_title(tab_info.active_pane.title)
-- 	end
-- end
--
-- https://github.com/wez/wezterm/discussions/4044
wezterm.on("toggle-opacity", function(window)
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
-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
-- 	local leading_bg = COLORS.leading_bg
-- 	local leading_fg = COLORS.leading_fg
-- 	local background = COLORS.background_inactive
-- 	local foreground = COLORS.foreground_inactive
-- 	local zoomed = ""
-- 	if tab.is_active then
-- 		background = COLORS.background_active
-- 		foreground = COLORS.foreground_active
-- 	elseif hover then
-- 		background = COLORS.background_hover
-- 		foreground = COLORS.foreground_hover
-- 	end
-- 	if tab.active_pane.is_zoomed then
-- 		zoomed = "+"
-- 	end
-- 	local text_right_arrow_fg = adjust_alpha(background, 0.75)
-- 	local text_right_arrow_bg = adjust_alpha(leading_bg, 1)
-- 	local text_left_arrow_fg = adjust_alpha(leading_bg, 0.75)
-- 	local text_left_arrow_bg = adjust_alpha(background, 1)
-- local title = tab_title(tab)
-- local pane = tab.active_pane
-- title = pane.pane_index
-- 	-- 确保标题适合可用空间，并保留边缘显示的空间
-- local index = ""
-- --
-- if #tabs > 1 then
-- 	index = string.format("%d ", tab.tab_index + 1)
-- end
--
-- 	return {
-- 		{ Attribute = { Italic = false } },
-- 		{ Attribute = { Intensity = hover and "Bold" or "Normal" } },
-- 		{ Background = { Color = leading_bg } },
-- 		{ Foreground = { Color = leading_fg } },
--
-- 		{ Background = { Color = text_left_arrow_bg } },
-- 		{ Foreground = { Color = text_left_arrow_fg } },
-- 		{ Text = SOLID_RIGHT_ARROW },
--
-- 		{ Background = { Color = background } },
-- 		{ Foreground = { Color = foreground } },
-- 		{ Text = " " .. index .. title .. " " .. zoomed .. " " },
--
-- 		{ Background = { Color = text_right_arrow_bg } },
-- 		{ Foreground = { Color = text_right_arrow_fg } },
-- 		{ Text = SOLID_RIGHT_ARROW },
-- 	}
-- end)

-- Scrollbar hidden
-- https://github.com/wez/wezterm/issues/4330
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local user_vars = pane:get_user_vars()
	local foreground_process = pane:get_foreground_process_name() or ""
	local is_tmux_or_zellij = user_vars.TMUX
		or user_vars.ZELLIJ
		or foreground_process:find("tmux")
		or foreground_process:find("zellij")
	if not overrides.colors then
		overrides.colors = config.colors or {}
	end
	-- wezterm.log_info("foreground_process: " .. foreground_process)
	if pane:is_alt_screen_active() then
		overrides.colors.scrollbar_thumb = "transparent"
		overrides.enable_scroll_bar = false
		if #pane:tab():panes() == 1 and is_tmux_or_zellij then
			overrides.hide_tab_bar_if_only_one_tab = true
		end
	else
		overrides.colors.scrollbar_thumb = nil
		overrides.enable_scroll_bar = true
		overrides.hide_tab_bar_if_only_one_tab = false
	end
	window:set_config_overrides(overrides)
	-- right status
	-- local date = wezterm.strftime("%a %b %-d %H:%M ")
	-- local date = wezterm.strftime("%H:%M ")
	--
	-- local bat = ""
	-- local leader = ""
	-- for _, b in ipairs(wezterm.battery_info()) do
	-- 	bat = "󰁹" .. string.format("%.1f%%", b.state_of_charge * 100)
	-- end
	-- if window:leader_is_active() then
	-- 	leader = "LEADER"
	-- 	overrides.colors.tab_bar = {
	-- 		background = "orange",
	-- 	}
	-- else
	-- 	overrides.colors.tab_bar = {
	-- 		background = COLORS.background_hover,
	-- 	}
	-- end
	-- window:set_right_status(wezterm.format({
	-- 	{ Text = leader .. "  " .. wezterm.mux.get_active_workspace() .. "  " .. bat .. "  " .. date },
	-- }))
end)

-- 基本配置
config.default_cursor_style = "BlinkingBar"
config.min_scroll_bar_height = "1cell"
config.color_scheme = auto_theme

-- 窗口配置
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.75
config.text_background_opacity = text_opacity
config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
	left = "0.9cell",
	right = "0.6cell",
	top = "5px",
	bottom = "0px",
}

-- 配色
config.colors = {
	-- compose_cursor = "orange",
	tab_bar = {
		-- text_background_opacity = 1.0,
		background = "rgba(0, 0, 0, 0.0)",
	},
}

-- 标签栏配置
config.enable_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false
config.tab_max_width = 50 -- +8
config.tab_bar_at_bottom = true
config.window_frame = {
	font_size = 8.0,
}

config.tab_bar_style = {
	-- 	new_tab = wezterm.format({
	-- 		{ Background = { Color = COLORS.new_tab_bg } },
	-- 		{ Foreground = { Color = COLORS.leading_bg } },
	-- 		{ Text = SOLID_RIGHT_ARROW },
	-- 		{ Background = { Color = COLORS.new_tab_bg } },
	-- 		{ Foreground = { Color = COLORS.new_tab_fg } },
	-- 		{ Text = " + " },
	-- 		{ Background = { Color = COLORS.leading_bg } },
	-- 		{ Foreground = { Color = COLORS.new_tab_bg } },
	-- 		{ Text = SOLID_RIGHT_ARROW },
	-- 	}),
	-- 	new_tab_hover = wezterm.format({
	-- 		{ Attribute = { Italic = false } },
	-- 		{ Attribute = { Intensity = "Bold" } },
	-- 		{ Background = { Color = COLORS.leading_bg } },
	-- 		{ Foreground = { Color = COLORS.leading_bg } },
	-- 		{ Text = SOLID_RIGHT_ARROW },
	-- 		{ Background = { Color = COLORS.leading_bg } },
	-- 		{ Foreground = { Color = COLORS.foreground_inactive } },
	-- 		{ Text = " + " },
	-- 		{ Background = { Color = COLORS.leading_bg } },
	-- 		{ Foreground = { Color = COLORS.leading_bg } },
	-- 		{ Text = SOLID_RIGHT_ARROW },
	-- 	}),
}
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

return config
