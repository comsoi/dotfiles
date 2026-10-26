local M = {}

M.general = {
	gaps_in     = 10,
	gaps_out    = 14,
	border_size = 2,
	col = {
		active_border   = "secondary_container",
		inactive_border = "primary_container",
	},
	resize_on_border = true,
	allow_tearing    = true,
	snap = {
		enabled     = true,
		window_gap  = 25,
		monitor_gap = 10,
	},
	layout = "scrolling",
}

M.decoration = {
	rounding           = 10,
	active_opacity     = 1.0,
	inactive_opacity   = 0.9,
	fullscreen_opacity = 1.0,
	blur = {
		enabled = true,
		size    = 6,
		passes  = 2,
	},
	shadow = {
		enabled      = true,
		range        = 30,
		render_power = 3,
		color        = 0x66000000,
	},
}

M.group = {
	groupbar = {
		height           = 16,
		indicator_height = 2,
		font_size        = 16,
		["col.active"]   = "primary_container",
		["col.inactive"] = "secondary_container",
		gaps_in          = 10,
	},
	["col.border_active"]   = "primary",
	["col.border_inactive"] = "secondary_container",
}

function M.apply(cfg)
	hl.config({ general    = M.general })
	hl.config({ decoration = M.decoration })
	hl.config({ group      = M.group })
end

return M
