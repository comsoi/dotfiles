local M = {}

-- 键位总览 / 可视化见 ../docs/keymap.html（由 docs/keymap_check.mjs 与本源核对）
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
