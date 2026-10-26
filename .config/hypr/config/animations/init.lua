-- Animation configuration
-- Active preset can be overridden via cfg.animations.preset

local M = {}

M.preset = "custom"

function M.apply(cfg)
	local preset = M.preset
	if cfg.animations and cfg.animations.preset then
		preset = cfg.animations.preset
	end
	require("config.animations." .. preset)
end

return M
