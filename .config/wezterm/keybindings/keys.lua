local wezterm = require("wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local act = wezterm.action

local M = {}

-- Helper functions
local function activate_pane_or_tab_callback(window, pane, dir, mods)
	local tab = pane:window():active_tab()
	local directions = {
		Left = { pane_check = "Left", tab_offset = -1 },
		Right = { pane_check = "Right", tab_offset = 1 },
		Prev = { pane_check = "Left", tab_offset = -1 },
		Next = { pane_check = "Right", tab_offset = 1 },
		Up = { pane_check = "Up", tab_offset = 0 },
		Down = { pane_check = "Down", tab_offset = 0 },
	}
	local dir_config = directions[dir]
	local action
	if #pane:window():tabs() > 1 then
		action = tab:get_pane_direction(dir_config.pane_check) ~= nil and wezterm.action.ActivatePaneDirection(dir)
			or wezterm.action.ActivateTabRelative(dir_config.tab_offset)
	else
		action = wezterm.action.ActivatePaneDirection(dir)
	end

	window:perform_action(action, pane)

	if mods and string.lower(mods):find("leader") then
		window:perform_action(
			act.ActivateKeyTable({ name = "activate_pane", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function activate_pane_or_tab(dir, mods)
	return function(window, pane)
		activate_pane_or_tab_callback(window, pane, dir, mods)
	end
end

local function resize_pane_with_dir(dir)
	return function(window, pane)
		window:perform_action(act.AdjustPaneSize({ dir, 10 }), pane)
		window:perform_action(
			act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function activate_tab_with_dir(dir)
	return function(window, pane)
		window:perform_action(act.ActivateTabRelative(dir), pane)
		window:perform_action(
			act.ActivateKeyTable({ name = "activate_tab", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function move_tab_with_dir(dir)
	return function(window, pane)
		window:perform_action(act.MoveTabRelative(dir), pane)
		window:perform_action(
			act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function smart_split_callback(window, pane)
	local dim = pane:get_dimensions()
	if dim.pixel_height > dim.pixel_width then
		window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
	else
		window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
	end
end

local function is_one_tab(pane)
	if #pane:window():tabs() == 1 then
		return true
	end
	return false
end

local function is_one_pane(pane)
	if #pane:tab():panes() == 1 then
		return true
	end
	return false
end

local function is_mux_or_sp(pane, tags)
	local foreground_process = pane:get_foreground_process_name() or ""
	local user_vars = pane:get_user_vars()

	if user_vars.TMUX or foreground_process:find("tmux") then
		return true
	end
	if user_vars.ZELLIJ or foreground_process:find("zellij") then
		return true
	end

	if tags == nil then
		tags = true
	end

	if tags then
		if user_vars.IS_NVIM == "true" or foreground_process:find("n?vim") then
			return true
		end
		if foreground_process:find("kitten") then
			return true
		end
	end

	return false
end

local ACTION_HANDLERS = {
	AdjustPaneSize = function(_, _, dir)
		return { AdjustPaneSize = { dir, 5 } }
	end,
	ActivatePaneDirection = function(window, pane, dir)
		local panes = pane:tab():panes_with_info()
		local is_zoomed = false
		for _, p in ipairs(panes) do
			if p.is_zoomed then
				is_zoomed = true
				break
			end
		end
		if is_zoomed then
			dir = (dir == "Up" or dir == "Right") and "Next" or "Prev"
		end
		if dir == "Left" or dir == "Right" then
			activate_pane_or_tab_callback(window, pane, dir)
			return
		end
		window:perform_action({ ActivatePaneDirection = dir }, pane)
		window:perform_action({ SetPaneZoomState = is_zoomed }, pane)
	end,
	ActivateTab = function(_, _, dir)
		return wezterm.action.ActivateTab(dir)
	end,
	ActivateTabRelative = function(_, _, dir)
		return wezterm.action.ActivateTabRelative(dir)
	end,
	MoveTabRelative = function(_, _, dir)
		return wezterm.action.MoveTabRelative(dir)
	end,
	SpawnTab = function(_, _, dir)
		return wezterm.action.SpawnTab(dir)
	end,
	CloseCurrentTab = function()
		return wezterm.action.CloseCurrentTab({ confirm = true })
	end,
	CloseCurrentPane = function()
		return wezterm.action.CloseCurrentPane({ confirm = true })
	end,
	smart_split = smart_split_callback,
}

local function create_keybind(action_str, mods, key, dir)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(window, pane)
			if is_mux_or_sp(pane, true) then
				window:perform_action({
					SendKey = { key = key, mods = mods },
				}, pane)
				return
			end
			local handler = ACTION_HANDLERS[action_str]
			if handler then
				local result = handler(window, pane, dir)
				if result then
					window:perform_action(result, pane)
				end
			else
				window:perform_action({
					SendKey = { key = key, mods = mods },
				}, pane)
			end
		end),
	}
end
--------------------------------------------------------------------------------

M.keys = {
	-- Normal
	create_keybind("SpawnTab", "ALT", "t", "CurrentPaneDomain"),
	create_keybind("SpawnTab", "ALT", "T", "CurrentPaneDomain"),
	create_keybind("smart_split", "ALT", "n"),
	create_keybind("smart_split", "ALT", "N"),
	create_keybind("CloseCurrentTab", "ALT", "q"),
	create_keybind("CloseCurrentTab", "ALT", "Q"),
	create_keybind("CloseCurrentPane", "ALT", "x"),
	create_keybind("CloseCurrentPane", "ALT", "X"),

	{ key = "V", mods = "SHIFT|CTRL", action = act({ PasteFrom = "Clipboard" }) },
	{ key = "C", mods = "SHIFT|CTRL", action = act({ CopyTo = "Clipboard" }) },
	{ key = "F", mods = "SHIFT|CTRL", action = act.Search({ CaseSensitiveString = "" }) },
	{ key = "P", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
	{ key = "+", mods = "SHIFT|CTRL", action = act.IncreaseFontSize },
	{ key = "_", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
	{ key = ")", mods = "SHIFT|CTRL", action = act.ResetFontSize },
	{ key = "F11", mods = "", action = "ToggleFullScreen" },

	{
		key = "a",
		mods = "CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "activate_pane", one_shot = false, timeout_milliseconds = 5000 }),
	},
	{
		key = "A",
		mods = "SHIFT|CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "activate_tab", one_shot = false, timeout_milliseconds = 5000 }),
	},
	{
		key = "r",
		mods = "CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 5000 }),
	},
	{
		key = "R",
		mods = "SHIFT|CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 5000 }),
	},

	-----------WORKSPACES----------
	{ key = "E", mods = "SHIFT|LEADER", action = workspace_switcher.switch_to_prev_workspace() },
	{ key = "e", mods = "LEADER", action = workspace_switcher.switch_workspace() },

	-----------PANE------------
	{ key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = false } }) },
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "m", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "S", mods = "SHIFT|LEADER", action = act.PaneSelect({ mode = "SwapWithActive" }) },
	{ key = "o", mods = "CTRL|LEADER", action = act.RotatePanes("Clockwise") },
	{ key = "o", mods = "ALT|LEADER", action = act.RotatePanes("CounterClockwise") },

	-- Pane navigation
	create_keybind("ActivatePaneDirection", "ALT", "h", "Left"),
	create_keybind("ActivatePaneDirection", "ALT", "j", "Down"),
	create_keybind("ActivatePaneDirection", "ALT", "k", "Up"),
	create_keybind("ActivatePaneDirection", "ALT", "l", "Right"),

	create_keybind("ActivatePaneDirection", "ALT", "[", "Prev"),
	create_keybind("ActivatePaneDirection", "ALT", "]", "Next"),

	{ key = "s", mods = "LEADER", action = act.PaneSelect({ alphabet = "123456789" }) },

	{ key = "o", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Next", "LEADER")) },
	{ key = "O", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Prev", "LEADER")) },

	{ key = "k", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Up", "LEADER")) },
	{ key = "j", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Down", "LEADER")) },
	{ key = "h", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Left", "LEADER")) },
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action_callback(activate_pane_or_tab("Right", "LEADER")),
	},
	{ key = "UpArrow", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Up", "LEADER")) },
	{ key = "DownArrow", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Down", "LEADER")) },
	{ key = "LeftArrow", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Left", "LEADER")) },
	{
		key = "RightArrow",
		mods = "LEADER",
		action = wezterm.action_callback(activate_pane_or_tab("Right", "LEADER")),
	},
	{ key = "h", mods = "ALT|CTRL", action = wezterm.action_callback(activate_pane_or_tab("Left")) },
	{ key = "l", mods = "ALT|CTRL", action = wezterm.action_callback(activate_pane_or_tab("Right")) },
	{ key = "k", mods = "ALT|CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "ALT|CTRL", action = act.ActivatePaneDirection("Down") },

	-- Pane resize
	create_keybind("AdjustPaneSize", "ALT", "LeftArrow", "Left"),
	create_keybind("AdjustPaneSize", "ALT", "RightArrow", "Right"),
	create_keybind("AdjustPaneSize", "ALT", "UpArrow", "Up"),
	create_keybind("AdjustPaneSize", "ALT", "DownArrow", "Down"),

	{ key = "H", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Left")) },
	{ key = "J", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Down")) },
	{ key = "K", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Up")) },
	{ key = "L", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Right")) },
	{ key = "UpArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Up")) },
	{ key = "DownArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Down")) },
	{ key = "LeftArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Left")) },
	{ key = "RightArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Right")) },
	{ key = "H", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Left", 10 }) },
	{ key = "J", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Down", 10 }) },
	{ key = "K", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Up", 10 }) },
	{ key = "L", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Right", 10 }) },

	-- Pane splitting
	{ key = "Enter", mods = "LEADER", action = wezterm.action_callback(smart_split_callback) },
	{ key = "Enter", mods = "ALT|CTRL", action = wezterm.action_callback(smart_split_callback) },
	{ key = "Enter", mods = "SHIFT|CTRL", action = wezterm.action_callback(smart_split_callback) },
	{ key = "-", mods = "ALT|CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "ALT|CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-----------TAB----------
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "&", mods = "SHIFT|LEADER", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "w", mods = "LEADER", action = act.ShowTabNavigator },
	{ key = "O", mods = "SHIFT|CTRL", action = act.ShowTabNavigator },

	-- Tab navigation
	{ key = "LeftArrow", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(1) },
	{ key = "[", mods = "ALT|CTRL", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "ALT|CTRL", action = act.ActivateTabRelative(1) },
	{ key = "n", mods = "LEADER", action = wezterm.action_callback(activate_tab_with_dir(1)) },
	{ key = "p", mods = "LEADER", action = wezterm.action_callback(activate_tab_with_dir(-1)) },
	{ key = "0", mods = "LEADER", action = act({ ActivateTab = -1 }) },
	{ key = "0", mods = "ALT|CTRL", action = act({ ActivateTab = -1 }) },
	create_keybind("ActivateTab", "ALT", "0", -1),

	-- Tab movement
	{ key = "<", mods = "SHIFT|CTRL", action = act.MoveTabRelative(-1) },
	{ key = ">", mods = "SHIFT|CTRL", action = act.MoveTabRelative(1) },
	{ key = "{", mods = "SHIFT|ALT|CTRL", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "SHIFT|ALT|CTRL", action = act.MoveTabRelative(1) },
	{ key = "P", mods = "SHIFT|LEADER", action = wezterm.action_callback(move_tab_with_dir(-1)) },
	{ key = "N", mods = "SHIFT|LEADER", action = wezterm.action_callback(move_tab_with_dir(1)) },

	-- Scrolling
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-0.5) },
	{ key = "PageUp", mods = "SHIFT|CTRL", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(0.5) },
	{ key = "PageDown", mods = "SHIFT|CTRL", action = act.ScrollByPage(1) },
	{ key = "Home", mods = "SHIFT|CTRL", action = act.ScrollToTop },
	{ key = "End", mods = "SHIFT|CTRL", action = act.ScrollToBottom },
	{ key = "K", mods = "SHIFT|CTRL", action = act.ScrollByLine(-3) },
	{ key = "J", mods = "SHIFT|CTRL", action = act.ScrollByLine(3) },
	{ key = "UpArrow", mods = "SHIFT|CTRL", action = act.ScrollByLine(-1) },
	{ key = "DownArrow", mods = "SHIFT|CTRL", action = act.ScrollByLine(1) },
	{ key = "k", mods = "SUPER", action = act.ClearScrollback("ScrollbackAndViewport") },
	{ key = "Delete", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
	-- OSC 133
	{ key = "UpArrow", mods = "SHIFT", action = act.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "SHIFT", action = act.ScrollToPrompt(1) },

	-- other
	{ key = "Space", mods = "LEADER", action = act.ShowLauncher },
	{ key = "Escape", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "[", mods = "CTRL|LEADER", action = act.ActivateCopyMode },
	{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "Space", mods = "SHIFT|CTRL", action = act.QuickSelect },
	{ key = "F1", mods = "NONE", action = act.ShowTabNavigator },
	{ key = "F12", mods = "LEADER", action = act.ShowDebugOverlay },
	{ key = "o", mods = "CTRL|LEADER", action = wezterm.action.EmitEvent("toggle-opacity") },
	{
		key = "W",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				window:perform_action(act({ CloseCurrentTab = { confirm = true } }), pane)
				return
			end
			if is_mux_or_sp(pane, false) and is_one_pane(pane) then
				window:perform_action(act.SendString("\x1b[87;6u"), pane)
				return
			end
			window:perform_action(act({ SpawnTab = "CurrentPaneDomain" }), pane)
			window:perform_action(act({ ActivateTabRelative = -1 }), pane)
			window:perform_action(act({ CloseCurrentTab = { confirm = true } }), pane)
		end),
	},
	{
		key = "T",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
				return
			end
			if is_mux_or_sp(pane, false) and is_one_pane(pane) then
				window:perform_action(act.SendString("\x1b[84;6u"), pane)
			else
				window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
			end
		end),
	},
	{
		key = "Tab",
		mods = "SHIFT|CTRL",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				window:perform_action(act.ActivateTabRelative(-1), pane)
				return
			end
			window:perform_action(act.SendString("\x1b[9;6u"), pane)
		end),
	},
	{
		key = "Tab",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				window:perform_action(act.ActivateTabRelative(1), pane)
				return
			end
			window:perform_action(act.SendString("\x1b[9;5u"), pane)
		end),
	},
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }), pane)
				window:perform_action("ClearSelection", pane)
			else
				window:perform_action(wezterm.action({ SendKey = { key = "c", mods = "CTRL" } }), pane)
			end
		end),
	},
	-- mux_window
	{
		key = "i",
		mods = "LEADER",
		action = wezterm.action.AttachDomain("unix"),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.DetachDomain({ DomainName = "unix" }),
	},
	{
		key = ".",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter target workspace(empty) for move",
			initial_value = "q",
			action = wezterm.action_callback(function(_, pane, line)
				if line == "q" or line == "quit" then
					return
				elseif line ~= "" then
					pane:move_to_new_window(line)
				else
					if #pane:window():tabs() == 1 then
						return
					end
					pane:move_to_new_window()
				end
			end),
		}),
	},
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "$",
		mods = "SHIFT|LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for workspace",
			action = wezterm.action_callback(function(_, _, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},
	{
		key = "!",
		mods = "LEADER | SHIFT",
		action = wezterm.action_callback(function(win, pane)
			local tab, window = pane:move_to_new_tab()
		end),
	},
	{
		key = "`",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({
			flags = "DOMAINS|WORKSPACES|TABS",
		}),
	},
}

function M.apply(config)
	for i = 1, 9 do
		table.insert(M.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
		table.insert(M.keys, { key = tostring(i), mods = "ALT|CTRL", action = act.ActivateTab(i - 1) })
		table.insert(M.keys, create_keybind("ActivateTab", "ALT", tostring(i), i - 1))
	end
	config.keys = M.keys
end

return M
