local M = {}

function M.apply(cfg)
	require("config.rules.window_rules.apps")
	require("config.rules.window_rules.workaround")
end

return M
