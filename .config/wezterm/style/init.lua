local M = {}

function M.apply(config)
	require("style.fonts").apply(config)
	require("style.appearance").apply(config)
	require("style.themes").apply(config)
	require("style.tab_config").apply(config)
	require("style.events").apply(config)
	require("style.workspace_switcher").apply()
end

return M
