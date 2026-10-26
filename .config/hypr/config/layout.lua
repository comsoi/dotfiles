local M = {}

M.dwindle = {
	preserve_split = true,
}

M.master = {
	mfact      = 0.67,
	new_on_top = true,
	new_status = "master",
}

M.scrolling = {
	fullscreen_on_one_column = true,
	column_width             = 0.66,
	follow_min_visible       = 0.8,
}

function M.apply(cfg)
	hl.config({ dwindle   = M.dwindle })
	hl.config({ master    = M.master })
	hl.config({ scrolling = M.scrolling })
end

return M
