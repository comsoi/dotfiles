local M = {}

M.workspace_swipe_distance = 500
M.workspace_swipe_forever  = true

function M.apply(cfg)
	hl.config({ gestures = {
		workspace_swipe_distance = M.workspace_swipe_distance,
		workspace_swipe_forever  = M.workspace_swipe_forever,
	} })

	hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
	hl.gesture({ fingers = 4, direction = "horizontal", mods = "ALT", scale = 0.5, action = "special", workspace = "term" })
	hl.gesture({ fingers = 4, direction = "vertical", action = "fullscreen" })
	hl.gesture({ fingers = 4, direction = "down", mods = "ALT", action = function() hypr.exec('amixer set Master "8%+"') end })
	hl.gesture({ fingers = 4, direction = "up", mods = "ALT", action = function() hypr.exec('amixer set Master "8%-"') end })
	hl.gesture({ fingers = 4, direction = "pinchin", scale = 0.8, action = "float" })
	hl.gesture({ fingers = 4, direction = "pinchout", action = function() hl.dispatch(hl.plugin.hyprexpo.expo("toggle")) end })
end

return M
