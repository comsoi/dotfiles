local M = {}

function M.apply(config)
	config.default_cursor_style = "BlinkingBar"
	config.enable_scroll_bar = true
	config.min_scroll_bar_height = "1cell"
	config.window_decorations = "RESIZE"
	config.window_background_opacity = 0.80
	config.use_resize_increments = true
	config.kde_window_background_blur = true
	config.text_background_opacity = 0.85
	config.adjust_window_size_when_changing_font_size = false

	config.window_padding = {
		left = "0.3cell",
		right = "0.3cell",
		top = "5px",
		bottom = "0px",
	}

	config.window_content_alignment = {
		horizontal = "Center",
		vertical = "Center",
	}

	config.inactive_pane_hsb = {
		hue = 1.0,
		saturation = 0.95,
		brightness = 0.80,
	}

	config.colors = {
		tab_bar = {
			background = "rgba(0, 0, 0, 0.0)",
		},
	}

	config.window_frame = {
		font_size = 9,
	}
end

return M
