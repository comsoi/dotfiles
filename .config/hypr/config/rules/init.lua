local M = {}

function M.apply(cfg)
	require("config.rules.window_rules").apply(cfg)
	require("config.rules.layer_rules").apply(cfg)
	require("config.rules.workspace_rules").apply(cfg)
end

return M
