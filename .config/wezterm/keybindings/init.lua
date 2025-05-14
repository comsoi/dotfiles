local M = {}

M.leader = {
	key = "Space",
	mods = "SHIFT",
	timeout_milliseconds = 3000,
}

function M.apply(config)
	config.enable_kitty_keyboard = true
	config.disable_default_key_bindings = true
	config.leader = M.leader
	require("keybindings.key_tables").apply(config)
	require("keybindings.keys").apply(config)
	require("keybindings.mouse").apply(config)
end

return M
