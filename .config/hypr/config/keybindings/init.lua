-- Keybindings entry point
-- Provides shared variables used by all sub-modules

local M = {}

function M.apply(cfg)
	require("config.keybindings.binds")
	require("config.keybindings.utilities")
	require("config.keybindings.standalone")
	require("config.keybindings.apps")
	require("config.keybindings.plugins")
	require("config.keybindings.submaps.passthru")
	require("config.keybindings.submaps.ctl")
	require("config.keybindings.submaps.gromit_mpx")
end

return M
