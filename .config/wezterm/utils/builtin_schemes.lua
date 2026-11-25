local wezterm = require("wezterm")
local M = {}

local schemes

function M.one(name)
	schemes = schemes or wezterm.color.get_builtin_schemes()
	return schemes[name]
end

return M
