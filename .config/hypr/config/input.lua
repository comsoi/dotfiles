local M = {}

M.numlock_by_default   = true
M.kb_layout            = "us"
M.kb_options           = "caps:escape_shifted_capslock,shift:both_capslock,terminate:ctrl_alt_bksp"
M.follow_mouse         = 1
M.mouse_refocus        = false
M.sensitivity          = 0.2
M.scroll_factor        = 1.0
M.special_fallthrough  = true

M.touchpad = {
	natural_scroll          = true,
	middle_button_emulation = true,
	clickfinger_behavior    = false,
	disable_while_typing    = true,
	scroll_factor           = 1.0,
}

function M.apply(cfg)
	hl.config({ input = {
		numlock_by_default   = M.numlock_by_default,
		kb_layout            = M.kb_layout,
		kb_options           = M.kb_options,
		follow_mouse         = M.follow_mouse,
		mouse_refocus        = M.mouse_refocus,
		sensitivity          = M.sensitivity,
		scroll_factor        = M.scroll_factor,
		special_fallthrough  = M.special_fallthrough,
		touchpad             = M.touchpad,
	} })
end

return M
