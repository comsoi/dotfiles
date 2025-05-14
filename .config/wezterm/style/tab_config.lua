local wezterm = require("wezterm")
local cmd_abbr = require("utils.cmd_abbr")
local M = {}

local function tab_title(tab_info)
	if not tab_info.is_active then
		if tab_info.active_pane.domain_name ~= "local" then
			return ""
		elseif #tab_info.tab_title > 0 then
			return tab_info.tab_title .. "|"
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

local function leader(window)
	if window:leader_is_active() then
		return " LEADER "
	end
	return ""
end

function M.apply(config)
	cmd_abbr.set_max_length(20)

	local tab_active = {}
	if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
		tab_active = {
			"index",
			"⌘ ",
			{ "cwd", padding = 0, max_length = 6 },
			{ "process" },
			tab_title,
			{ "zoomed", padding = 0 },
		}
	elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
		tab_active = {
			"index",
			"⌘ ",
			tab_title,
			{ "zoomed", padding = 0 },
		}
	end

	local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
	tabline.setup({
		sections = {
			tabline_c = { leader },
			tab_active = tab_active,
			tab_inactive = {
				{ "index", padding = 0 },
				". ",
				tab_title,
				{ "process", padding = { left = 0, right = 1 } },
			},
			tabline_x = { { "cpu", throttle = 5 } },
		},
		extensions = { "smart_workspace_switcher" },
	})

	-- 标签栏基础配置
	config.enable_tab_bar = true
	config.show_new_tab_button_in_tab_bar = false
	config.use_fancy_tab_bar = false
	config.show_close_tab_button_in_tabs = false
	config.hide_tab_bar_if_only_one_tab = false
	config.show_tab_index_in_tab_bar = false
	config.tab_max_width = 50
	config.tab_bar_at_bottom = true
	-- config.tab_bar_style = {
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
	-- }
end

return M
