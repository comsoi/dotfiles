local M = {}

function M.apply(cfg)
	require("config.rules.workspace_rules.workspaces")
	require("config.rules.workspace_rules.special_ws")
end

return M
