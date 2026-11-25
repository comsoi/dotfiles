local wezterm = require("wezterm")
local M = {}

local handlers = {}

function M.on(name, handler)
	handlers[name] = handler
end

function M.install()
	if rawget(_G, "__user_var_installed") then
		return
	end
	rawset(_G, "__user_var_installed", true)
	wezterm.on("user-var-changed", function(window, pane, name, value)
		local handler = handlers[name]
		if handler then
			handler(window, pane, value)
		end
	end)
end

return M
