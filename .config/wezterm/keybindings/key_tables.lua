local act = require("wezterm").action

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
		{ key = "P", action = act.MoveTab(999), mods = "SHIFT" },
		{ key = "N", action = act.MoveTab(1), mods = "SHIFT" },

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
		{ key = "Escape", mods = "NONE", action = act.CopyMode("ClearSelectionMode") },
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
