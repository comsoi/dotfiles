local M = {}

function M.apply(config)
	local fonts = require("style.fonts")
	local appearance = require("style.appearance")
	local themes = require("style.themes")
	local tab_config = require("style.tab_config")
	local events = require("style.events")

	fonts.apply(config)
	appearance.apply(config)
	themes.apply(config)
	tab_config.apply(config)
	events.apply(config)
	require("style.workspace_switcher").apply()
end

return M
