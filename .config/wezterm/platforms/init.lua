-- 平台分发：先应用通用设置（platforms/general.lua），再按 target_triple 加载对应平台模块
-- 判断逻辑本身在 utils/target.lua（业务无关，platforms/ 与 utils/ 共用）。

local target = require("utils.target")

local M = {}

function M.is_linux()
	return target.is_linux()
end

function M.is_windows()
	return target.is_windows()
end

function M.is_macos()
	return target.is_macos()
end

function M.apply(config)
	require("platforms.general").apply(config)
	if M.is_linux() then
		require("platforms.linux").apply(config)
	elseif M.is_windows() then
		require("platforms.windows").apply(config)
	end
end

return M
