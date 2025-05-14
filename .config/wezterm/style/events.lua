local wezterm = require("wezterm")
local M = {}

function M.apply(config)
	-- Toggle opacity
	-- https://github.com/wez/wezterm/discussions/4044
	wezterm.on("toggle-opacity", function(window)
		local overrides = window:get_config_overrides() or {}

		local default_window_opacity = config.window_background_opacity
		local default_text_opacity = config.text_background_opacity

		if not overrides.window_background_opacity or overrides.window_background_opacity == default_window_opacity then
			overrides.window_background_opacity = 1
			overrides.text_background_opacity = 1
		else
			overrides.window_background_opacity = default_window_opacity
			overrides.text_background_opacity = default_text_opacity
		end

		window:set_config_overrides(overrides)
	end)

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

		if pane:is_alt_screen_active() then
			overrides.colors.scrollbar_thumb = "transparent"
			-- overrides.enable_scroll_bar = false
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
end

return M
