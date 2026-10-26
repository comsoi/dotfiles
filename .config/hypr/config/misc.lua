local M = {}

M.misc = {
	disable_hyprland_logo        = true,
	disable_splash_rendering     = true,
	disable_watchdog_warning     = true,
	enable_anr_dialog            = false,
	animate_manual_resizes       = false,
	animate_mouse_windowdragging = false,
}

M.binds = {
	scroll_event_delay          = 10,
	workspace_back_and_forth    = true,
	allow_workspace_cycles      = true,
	movefocus_cycles_fullscreen = 0,
	disable_keybind_grabbing    = true,
}

M.xwayland = {
	force_zero_scaling     = true,
	create_abstract_socket = true,
}

function M.apply(cfg)
	hl.config({ misc     = M.misc })
	hl.config({ binds    = M.binds })
	hl.config({ xwayland = M.xwayland })
end

return M
