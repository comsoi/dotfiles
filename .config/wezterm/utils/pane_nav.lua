-- 「同方向还有 pane 就过去，到边缘则左右跨 tab」的唯一实现。两个调用方共用，
-- 避免语义漂移：
--   1. keybindings/keys.lua       —— 直接按 <Leader>h/j/k/l 之类的按键
--   2. utils/smart_splits_req.lua —— nvim 通过 SMART_SPLITS_REQ 发来的请求
--      （nvim 自己窗口已经到头时才会发，语义与按键完全一致）
local wezterm = require("wezterm")

local M = {}

-- Prev/Next 与 Left/Right 同义，只是名字来自 Leader 层的 o/O
local directions = {
	Left = { pane_check = "Left", tab_offset = -1 },
	Right = { pane_check = "Right", tab_offset = 1 },
	Prev = { pane_check = "Left", tab_offset = -1 },
	Next = { pane_check = "Right", tab_offset = 1 },
	Up = { pane_check = "Up", tab_offset = 0 },
	Down = { pane_check = "Down", tab_offset = 0 },
}

---@param window any WezTerm GuiWindow
---@param pane any 当前 pane
---@param dir "Left"|"Right"|"Up"|"Down"|"Prev"|"Next"
---@return boolean 是否执行了动作
function M.activate_pane_or_tab(window, pane, dir)
	local cfg = directions[dir]
	if not cfg then
		return false
	end

	local action
	-- 用 pane:tab() 而不是 window:active_tab()：请求是从"发 OSC 的那个 pane"来的，
	-- 焦点可能已经移到别的 tab，这时 active_tab() 会指错目标（按键路径两者相同）。
	local tab = pane:tab()
	if #pane:window():tabs() > 1 and tab then
		action = tab:get_pane_direction(cfg.pane_check) ~= nil and wezterm.action.ActivatePaneDirection(dir)
			or wezterm.action.ActivateTabRelative(cfg.tab_offset)
	else
		action = wezterm.action.ActivatePaneDirection(dir)
	end

	window:perform_action(action, pane)
	return true
end

return M
