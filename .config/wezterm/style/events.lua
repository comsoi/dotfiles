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

	wezterm.on("save-output", function(window, pane)
		--https://github.com/wezterm/wezterm/discussions/2343
		local zones = pane:get_semantic_zones()
		local i = #zones
		local last_index = nil
		while i > 0 and not last_index do
			if zones[i].semantic_type == "Output" then
				last_index = i
			end
			i = i - 1
		end

		if not last_index then
			return nil
		end
		local latest_output_zone = zones[last_index]
		local text = pane:get_text_from_semantic_zone(latest_output_zone)
		if text == nil then
			return nil
		end
		io.popen("wl-copy", "w"):write(text):close()
	end)

	-- Scrollbar hidden
	-- https://github.com/wez/wezterm/issues/4330
	wezterm.on("update-status", function(window, pane)
		local overrides = window:get_config_overrides() or {}
		local user_vars = pane:get_user_vars()

		if not overrides.colors then
			overrides.colors = config.colors or {}
		end

		if pane:is_alt_screen_active() then
			overrides.colors.scrollbar_thumb = "transparent"
			if user_vars.TMUX or user_vars.ZELLIJ and #pane:tab():panes() == 1 then
				overrides.hide_tab_bar_if_only_one_tab = true
			end
		else
			overrides.colors.scrollbar_thumb = nil
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
