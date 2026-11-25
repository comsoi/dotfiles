-- 每 tick 的动态 UI：alt-screen 时把滚动条调成透明，且在复用器里只有一个 pane 时隐藏 tab 条。
-- 只在状态真的变化时才写 config override，避免每秒重绘。
-- handler 自己 pcall 兜异常 —— 原因见 M.apply 里的注释（wezterm 的 emit_event 会让
-- handler 异常中断整条 handler 链）。
-- https://github.com/wez/wezterm/issues/4330

local wezterm = require("wezterm")
local mux = require("utils.mux")
local config_overrides = require("utils.config_overrides")
local M = {}

function M.apply(config)
	-- 这个 handler 抛异常不是"少做一件事"那么轻：wezterm 的 emit_event 是
	-- `func.call_async(args).await?`，那个 `?` 会让**整条 handler 链**中断 ——
	-- 注册在它后面的 handler 这一 tick 全部不跑（tabline 的状态更新也在其中）。
	-- 日志里实际发生过一次，所以自己兜一层，并且只喊一次（每秒一次的 handler 刷屏没意义）。
	local tick_failed = false

	wezterm.on("update-status", function(window, pane)
		local ok, err = pcall(function()
			-- pane 可能在两次 tick 之间被关掉，此后任何 pane: 方法都会抛
			-- "pane id N not found in mux"（日志实证：is_alt_screen_active）。
			-- 这是正常竞态不是异常：判不出来就什么都不改，维持上一 tick 的状态。
			local ok_alt, alt = pcall(pane.is_alt_screen_active, pane)
			if not ok_alt then
				return
			end

			local overrides = window:get_config_overrides() or {}

			local want_thumb
			local want_hide
			if alt then
				want_thumb = "transparent"
				-- 锁定时保留 tab 条：tabline 上要显示锁字形（keys.lua 的清空 keys 即锁定）
				local is_locked = overrides.keys ~= nil
				want_hide = mux.is_mux(pane) and #pane:tab():panes() == 1 and not is_locked
			else
				want_hide = false
			end
			-- nil = **清掉**这个 override（回落到基础配置），而不是"不要动"。
			-- 原来用 nil 表示"不要动"，于是先前写下的 true 永远清不掉：按下锁定、或在 nvim 里
			-- 拆出第二个 pane 之后，tab 条仍然隐藏（锁字形因此根本看不见）。
			local want_hide_override = want_hide and true or nil

			local cur_thumb = overrides.colors and overrides.colors.scrollbar_thumb or nil
			local cur_hide = overrides.hide_tab_bar_if_only_one_tab
			if cur_thumb == want_thumb and cur_hide == want_hide_override then
				return
			end

			-- colors 必须给整表、且是独立副本（原因见 utils/config_overrides.lua）：
			-- 直接 alias config.colors 会让这里把 tab_collapse 刚设的 tab bar 底色打回默认
			config_overrides.update_colors(window, overrides, config.colors, function(ov, colors)
				colors.scrollbar_thumb = want_thumb -- nil 同样表示清掉，回落基础配置
				ov.hide_tab_bar_if_only_one_tab = want_hide_override
			end)
		end)
		if not ok and not tick_failed then
			tick_failed = true
			wezterm.log_error("dynamic_ui: update-status 出错（后续同样错误不再重复报告）: " .. tostring(err))
		end
	end)
end

return M
