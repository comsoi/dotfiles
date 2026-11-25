local M = {}

function M.apply(config)
	require("style.appearance").apply(config)
	require("style.color_scheme").apply(config)
	require("style.fonts").apply(config)
	require("style.tabline").apply(config)
	require("style.opacity").apply(config)
	-- update-status 的 handler 按注册顺序**全部**执行（与 format-tab-title 不同，那个只跑
	-- 第一个，见 style/tabline/collapse.lua 头部），动态 UI 必须排在 tab_bar（tabline setup）之后。
	-- 注意：handler 里绝不要 `return false` —— wezterm 视其为 "Default action prevented"，
	-- 会跳过注册在其后的所有 handler（config/src/lua.rs 的 emit_event）。返回 nil 没事。
	require("style.dynamic_ui").apply(config)
	require("style.workspace_switcher").apply(config)
end

return M
