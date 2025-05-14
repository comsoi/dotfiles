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
}

function M.apply(config)
	config.key_tables = M.key_tables
end

return M
