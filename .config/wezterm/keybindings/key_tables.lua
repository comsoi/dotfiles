local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

M.key_tables = {
	resize_pane = {
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 10 }), mods = "SHIFT" },
		{ key = "H", action = act.AdjustPaneSize({ "Left", 10 }), mods = "SHIFT" },

		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 10 }), mods = "SHIFT" },
		{ key = "L", action = act.AdjustPaneSize({ "Right", 10 }), mods = "SHIFT" },

		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 10 }), mods = "SHIFT" },
		{ key = "K", action = act.AdjustPaneSize({ "Up", 10 }), mods = "SHIFT" },

		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 10 }), mods = "SHIFT" },
		{ key = "J", action = act.AdjustPaneSize({ "Down", 10 }), mods = "SHIFT" },

		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "Q", action = "PopKeyTable" },
	},
	activate_pane = {
		{ key = "LeftArrow", action = act.ActivatePaneDirection("Left") },
		{ key = "h", action = act.ActivatePaneDirection("Left") },

		{ key = "RightArrow", action = act.ActivatePaneDirection("Right") },
		{ key = "l", action = act.ActivatePaneDirection("Right") },

		{ key = "UpArrow", action = act.ActivatePaneDirection("Up") },
		{ key = "k", action = act.ActivatePaneDirection("Up") },

		{ key = "DownArrow", action = act.ActivatePaneDirection("Down") },
		{ key = "j", action = act.ActivatePaneDirection("Down") },

		{ key = "o", action = act.ActivatePaneDirection("Next") },
		{ key = "O", action = act.ActivatePaneDirection("Prev") },

		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "Q", action = "PopKeyTable" },
	},
	move_tab = {
		-- 与下面 activate_tab 表同约定：P = 第一个，N = 最后一个（索引 0 起）。
		--
		-- 别写成一个大数当"最后"：MoveTab 对越界不做钳位，
		-- termwindow/mod.rs 的 `ensure!(tab_idx < max, "cannot move a tab out of range")`
		-- 会直接返回 Err，而 keyevent.rs 又把 Err 当成"已处理"（`Err(_) => true`）——
		-- 结果是按键静默无效，既不提示也不写日志。原来这里的 MoveTab(999) 就是死键。
		{ key = "P", action = act.MoveTab(0), mods = "SHIFT" },
		{
			key = "N",
			mods = "SHIFT",
			action = wezterm.action_callback(function(window, pane)
				-- 注意 window 是 GuiWindow，**没有** tabs()；pane:window() 返回的 MuxWindow 才有
				window:perform_action(act.MoveTab(#pane:window():tabs() - 1), pane)
			end),
		},

		{ key = "p", action = act.MoveTabRelative(-1) },
		{ key = "n", action = act.MoveTabRelative(1) },

		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "Q", action = "PopKeyTable" },
	},
	activate_tab = {
		{ key = "N", action = act.ActivateTab(-1) },
		{ key = "P", action = act.ActivateTab(0) },

		{ key = "n", action = act.ActivateTabRelative(1) },
		{ key = "p", action = act.ActivateTabRelative(-1) },

		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "Q", action = "PopKeyTable" },
	},
	-- wezterm show-keys --lua --key-table copy_mode
	copy_mode = {
		-- 编辑搜索模式（EditPattern）
		{ key = "e", mods = "CTRL", action = act.CopyMode("EditPattern") },
		{ key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{ key = "End", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "Home", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "LeftArrow", mods = "CTRL", action = act.CopyMode("MoveBackwardWord") },
		{ key = "RightArrow", mods = "CTRL", action = act.CopyMode("MoveForwardWord") },
		{ key = "Tab", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
		{ key = "Tab", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		-- vim style keys
		-- Esc 两段式：有选区先取消选择（留在复制模式），没有选区才退出（回底 + 关闭）。
		-- ClearSelectionMode 会连选区一起清（overlay/copy.rs 的 clear_selection_mode），
		-- 所以判一次 get_selection_text_for_pane 是否为空就能区分"第一次 / 第二次"。
		{
			key = "Escape",
			mods = "NONE",
			action = wezterm.action_callback(function(window, pane)
				if window:get_selection_text_for_pane(pane) ~= "" then
					window:perform_action(act.CopyMode("ClearSelectionMode"), pane)
				else
					window:perform_action(act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }), pane)
				end
			end),
		},
		{ key = "c", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
		{ key = "i", mods = "NONE", action = act.Multiple({ act.ClearSelection, { CopyMode = "Close" } }) },
		-- vim move
		{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
		{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
		-- vim scroll
		{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
		{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
		--- vim visual
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
		-- vim jump
		{ key = "F", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
		{ key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
		{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		-- 复制到剪贴板并回到底部
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				{ Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
			}),
		},
		{ key = "J", mods = "NONE", action = act.CopyMode("MoveForwardSemanticZone") },
		{ key = "K", mods = "NONE", action = act.CopyMode("MoveBackwardSemanticZone") },
		{ key = "n", mods = "NONE", action = act.CopyMode("MoveForwardSemanticZone") },
		{ key = "p", mods = "NONE", action = act.CopyMode("MoveBackwardSemanticZone") },
		{ key = "x", mods = "NONE", action = act.CopyMode("MoveForwardSemanticZone") },
		{ key = "z", mods = "NONE", action = act.CopyMode("MoveBackwardSemanticZone") },
	},
	-- copy_mode = {
}

function M.apply(config)
	config.key_tables = M.key_tables
end

return M
