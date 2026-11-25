-- 接住 nvim 侧 smart-splits 发来的请求。
--
-- 通道是 OSC 1337 SetUserVar=SMART_SPLITS_REQ（nvim 写在 stderr 上，wezterm 解析后触发
-- user-var-changed），载荷是 JSON：{ action = "move"|"resize", dir = "left"|..., amount? }。
-- nvim 只在自己的窗口已经到头（没有可移动的窗口）时才发，所以到边缘之后怎么办由这里决定。
--
-- 注意这不是按键：nvim 已经把键消化掉了，没有"透传回 pane"这个回退选项——只能真的执行
-- 动作，或者什么都不做。方向语义与按键路径共用 utils/pane_nav.lua，保证两边一致。
--
-- 现在就装上，但要等 nvim 侧换到 smart-splits v3（backend-wezterm）才会真的收到东西；
-- v2 不发这个 user var，所以在此之前完全是惰性的。
local wezterm = require("wezterm")
local pane_nav = require("utils.pane_nav")

local M = {}

local DIR = { left = "Left", right = "Right", up = "Up", down = "Down" }

local function do_resize(window, pane, dir, amount)
	window:perform_action(wezterm.action.AdjustPaneSize({ dir, amount or 1 }), pane)
end

---@param value string JSON 载荷
---@return boolean 是否处理了这个请求
function M.handle(window, pane, value)
	local ok, req = pcall(wezterm.json_parse, value)
	if not ok or type(req) ~= "table" then
		return false
	end
	local dir = DIR[tostring(req.dir or "")]
	if not dir then
		return false
	end

	if req.action == "resize" then
		local amount = tonumber(req.amount)
		do_resize(window, pane, dir, amount and math.max(1, math.floor(amount)) or nil)
	else
		pane_nav.activate_pane_or_tab(window, pane, dir)
	end
	return true
end

-- 用全局标记保证每个 Lua 状态只注册一次（配置重载会重建 Lua 状态，标记随之重置）
function M.apply()
	if rawget(_G, "__smart_splits_req_registered") then
		return
	end
	rawset(_G, "__smart_splits_req_registered", true)
	wezterm.on("user-var-changed", function(window, pane, name, value)
		if name == "SMART_SPLITS_REQ" then
			M.handle(window, pane, value)
		end
	end)
end

return M
