-- Plugin configuration (hyprpm)

local M = {}

function M.apply(cfg)
	hl.on("hyprland.start", function()
		hypr.exec("hyprpm reload")
	end)

	-- hyprbars

	if utils.is_plugin_loaded("hyprbars") then
		hl.config({
			plugin = {
				hyprbars = {
					bar_height = 26,
					bar_color = primary_container,
					bar_text_size = 13,
					bar_text_font = "PingFang SC, Jetbrains Mono Nerd Font Mono Bold",
					bar_button_padding = 10,
					bar_padding = 8,
					bar_precedence_over_border = true,
				},
			},
		})

		hl.plugin.hyprbars.add_button({
			bg_color = on_error_container,
			fg_color = primary_container,
			size = 20,
			icon = "",
			action = "hyprctl dispatch 'hl.dsp.window.close()'",
		})
		hl.plugin.hyprbars.add_button({
			bg_color = secondary,
			fg_color = primary_container,
			size = 20,
			icon = "󰖯",
			action = "hyprctl dispatch 'hl.dsp.window.fullscreen_state({ internal = 2, client = 1, action = \"toggle\" })'",
		})
		hl.plugin.hyprbars.add_button({
			bg_color = primary,
			fg_color = primary_container,
			size = 20,
			icon = "󰖰",
			action = "hyprctl dispatch 'hl.dsp.window.move({ workspace = \"special\" })'",
		})
		hl.plugin.hyprbars.add_button({
			bg_color = on_surface,
			fg_color = primary_container,
			size = 14,
			icon = "",
			action = "hyprctl dispatch 'hl.dsp.window.float({ action = \"toggle\" })'",
		})

		hl.window_rule({
			name = "hyprbars-no-float",
			match = { float = false },
		})

		hl.window_rule({
			name = "hyprbars-no-wechat",
			match = {
				class = "^wechat$",
				initial_title = "^wechat$",
				float = true,
				xwayland = true,
			},
		})
	end

	-- csgo-vulkan-fix
	if utils.is_plugin_loaded("csgo_vulkan_fix") then
		hl.config({
			plugin = {
				csgo_vulkan_fix = {
					fix_mouse = true,
				},
			},
		})
		hl.plugin.csgo_vulkan_fix.vkfix_app({ app = "cs2", w = 1650, h = 1050 })
	end

	-- hyprfocus
	if utils.is_plugin_loaded("hyprfocus") then
		hl.config({
			plugin = {
				hyprfocus = {
					mode = "slide",
					fade_opacity = 0.85,
					only_on_monitor_change = true,
				},
			},
		})

		hl.animation({ leaf = "hyprfocusIn", enabled = true, speed = 3.5, bezier = "default" })
		hl.animation({ leaf = "hyprfocusOut", enabled = true, speed = 2.5, bezier = "default" })
	end

	-- split-monitor-workspaces
	if utils.is_plugin_loaded("split-monitor-workspaces") then
		hl.config({
			plugin = {
				split_monitor_workspaces = {
					count = 10,
					keep_focused = 1,
					enable_notifications = 0,
					enable_persistent_workspaces = 0,
					enable_wrapping = 1,
					link_monitors = 0,
					enable_hy3 = 0,
				},
			},
		})
		-- if HDMI-A-1 exists, put it before eDP-1, otherwise the workspace will be created on eDP-1 by default
		if hl.get_monitor("HDMI-A-1") then
			hl.plugin.split_monitor_workspaces.monitor_priority({ "HDMI-A-1", "eDP-1" })
		end
	end

	if utils.is_plugin_loaded("hymission") then
		hl.config({
			plugin = {
				hymission = {
					workspace_strip_anchor = "top",
					layout_engine = "nature",
					-- one_workspace_per_row = 1,
					only_active_monitor = 1,
					show_focus_indicator = 1,
					switch_release_key = "ALT_L",
				},
			},
		})
	end
end

return M
