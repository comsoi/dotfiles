local wezterm = require("wezterm")
local act = wezterm.action

-- key bindings
local leader = {
	-- win + alt + space
	key = 'Space',
	mods = 'SUPER|ALT',
	timeout_milliseconds = math.maxinteger
}


local key_tables = {
	resize_pane = {
		{ key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
		{ key = 'h',          action = act.AdjustPaneSize { 'Left', 1 } },
		{ key = 'H',          action = act.AdjustPaneSize { 'Left', 10 } },

		{ key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
		{ key = 'l',          action = act.AdjustPaneSize { 'Right', 1 } },
		{ key = 'L',          action = act.AdjustPaneSize { 'Right', 10 } },

		{ key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
		{ key = 'k',          action = act.AdjustPaneSize { 'Up', 1 } },
		{ key = 'K',          action = act.AdjustPaneSize { 'Up', 10 } },

		{ key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
		{ key = 'j',          action = act.AdjustPaneSize { 'Down', 1 } },
		{ key = 'J',          action = act.AdjustPaneSize { 'Down', 10 } },

		{ key = 'Escape',     action = 'PopKeyTable' },
		{ key = 'q',          action = 'PopKeyTable' },
		{ key = 'Q',          action = 'PopKeyTable' }
	},
	activate_pane = {
		{ key = 'LeftArrow',  action = act.ActivatePaneDirection 'Left' },
		{ key = 'h',          action = act.ActivatePaneDirection 'Left' },

		{ key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
		{ key = 'l',          action = act.ActivatePaneDirection 'Right' },

		{ key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
		{ key = 'k',          action = act.ActivatePaneDirection 'Up' },

		{ key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },
		{ key = 'j',          action = act.ActivatePaneDirection 'Down' },

		{ key = 'Escape',     action = 'PopKeyTable' },
		{ key = 'q',          action = 'PopKeyTable' },
		{ key = 'Q',          action = 'PopKeyTable' }
	},
	move_tab = {
		{ key = 'N',          action = act.MoveTabRelative(1) },
		{ key = 'P',          action = act.MoveTabRelative(-1) },

		{ key = 'n',          action = act.MoveTabRelative(1) },
		{ key = 'p',          action = act.MoveTabRelative(-1) },

		{ key = 'h',          action = act.MoveTabRelative(-1) },
		{ key = 'j',          action = act.MoveTabRelative(1) },
		{ key = 'k',          action = act.MoveTabRelative(-1) },
		{ key = 'l',          action = act.MoveTabRelative(1) },

		{ key = 'LeftArrow',  action = act.MoveTabRelative(-1) },
		{ key = 'RightArrow', action = act.MoveTabRelative(1) },
		{ key = 'UpArrow',    action = act.MoveTabRelative(-1) },
		{ key = 'DownArrow',  action = act.MoveTabRelative(1) },

		{ key = 'Escape',     action = 'PopKeyTable' },
		{ key = 'q',          action = 'PopKeyTable' },
		{ key = 'Q',          action = 'PopKeyTable' }
	},
	activate_tab = {
		{ key = 'N',          action = act.ActivateTab(-1) },
		{ key = 'P',          action = act.ActivateTab(0) },

		{ key = 'n',          action = act.ActivateTabRelative(1) },
		{ key = 'p',          action = act.ActivateTabRelative(-1) },

		{ key = 'h',          action = act.ActivateTabRelative(-1) },
		{ key = 'j',          action = act.ActivateTabRelative(1) },
		{ key = 'k',          action = act.ActivateTabRelative(-1) },
		{ key = 'l',          action = act.ActivateTabRelative(1) },

		{ key = 'LeftArrow',  action = act.ActivateTabRelative(-1) },
		{ key = 'RightArrow', action = act.ActivateTabRelative(1) },
		{ key = 'UpArrow',    action = act.ActivateTabRelative(-1) },
		{ key = 'DownArrow',  action = act.ActivateTabRelative(1) },

		{ key = 'Escape',     action = 'PopKeyTable' },
		{ key = 'q',          action = 'PopKeyTable' },
		{ key = 'Q',          action = 'PopKeyTable' }
	}
}

-- Helper functions
--------------------------------------------------------------------------------
-- enable actions for activating and resizing panes similar to tmux.
local function activate_pane_with_dir(dir)
	return function(win, pane)
		win:perform_action(act.ActivatePaneDirection(dir), pane)
		win:perform_action(act.ActivateKeyTable { name = 'activate_pane', one_shot = false, timeout_milliseconds = 600 },
			pane)
	end
end

local function resize_pane_with_dir(dir)
	return function(win, pane)
		win:perform_action(act.AdjustPaneSize { dir, 10 }, pane)
		win:perform_action(act.ActivateKeyTable { name = 'resize_pane', one_shot = false, timeout_milliseconds = 600 },
			pane)
	end
end

local function activate_tab_with_dir(dir)
	return function(win, pane)
		win:perform_action(act.ActivateTabRelative(dir), pane)
		win:perform_action(act.ActivateKeyTable { name = 'activate_tab', one_shot = false, timeout_milliseconds = 600 },
			pane)
	end
end

local function move_tab_with_dir(dir)
	return function(win, pane)
		win:perform_action(act.MoveTabRelative(dir), pane)
		win:perform_action(act.ActivateKeyTable { name = 'move_tab', one_shot = false, timeout_milliseconds = 600 },
			pane)
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

local function is_nvim_or_tmux_or_zellij(pane)
	local foreground_process = pane:get_foreground_process_name() or ""
	local user_vars = pane:get_user_vars()
	if user_vars.IS_TMUX == "true" or foreground_process:find("tmux") then
		return true
	end
	if user_vars.IS_ZELLIJ == "true" or foreground_process:find("zellij") then
		return true
	end
	if user_vars.IS_NVIM == "true" or foreground_process:find("n?vim") then
		return true
	end
	if foreground_process:find("kitten") then
		return true
	end
	return false
end

local function activate_pane_and_tab(window, pane, dir)
	local tab = window:mux_window():active_tab()
	local directions = {
		Left = { pane_check = "Left", tab_offset = -1 },
		Right = { pane_check = "Right", tab_offset = 1 }
	}

	local dir_config = directions[dir]
	local action = tab:get_pane_direction(dir_config.pane_check) ~= nil
			and wezterm.action.ActivatePaneDirection(dir_config.pane_check)
			or wezterm.action.ActivateTabRelative(dir_config.tab_offset)

	window:perform_action(action, pane)
end
-- local function activate_pane_prev(window, pane)
-- 	local tab = window:mux_window():active_tab()
-- 	local panes = tab:panes_with_info()
-- 	local max_panes = 0
-- 	for _, p in ipairs(panes) do
-- 		if p.pane_index > max_panes then
-- 			max_panes = p.pane_index
-- 		end
-- 	end
-- 	local max_tabs = 0
-- 	for _, t in ipairs(window:mux_window():tabs()) do
-- 		if t.tab_index > max_tabs then
-- 			max_tabs = t.tab_index
-- 		end
-- 	end


-- 	if max_tabs == 1 then
-- 		window:perform_action(wezterm.action.ActivatePaneDirection("Prev"), pane)
-- 	else
-- 		if pane.pane_index ~= 0 then
-- 			window:perform_action(wezterm.action.ActivatePaneDirection("Prev"), pane)
-- 		else
-- 			window:perform_action(wezterm.action.ActivateTabRelative(-1), pane)
-- 		end
-- 	end
-- end

local ACTION_HANDLERS = {
	AdjustPaneSize = function(win, pane, dir)
		return { AdjustPaneSize = { dir, 5 } }
	end,
	ActivatePaneDirection = function(win, pane, dir)
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
			activate_pane_and_tab(win, pane, dir)
			return
		end
		win:perform_action({ ActivatePaneDirection = dir }, pane)
		win:perform_action({ SetPaneZoomState = is_zoomed }, pane)
	end,
	ActivateTab = function(win, pane, dir)
		return wezterm.action.ActivateTab(dir)
	end,
	ActivateTabRelative = function(win, pane, dir)
		return wezterm.action.ActivateTabRelative(dir)
	end,
	MoveTabRelative = function(win, pane, dir)
		return wezterm.action.MoveTabRelative(dir)
	end,
	SpawnTab = function(win, pane, dir)
		return wezterm.action.SpawnTab(dir)
	end,
	CloseCurrentTab = function()
		return wezterm.action.CloseCurrentTab { confirm = true }
	end,
	CloseCurrentPane = function()
		return wezterm.action.CloseCurrentPane { confirm = true }
	end,
	smart_split = smart_split_callback,
}

local function create_keybind(action_str, mods, key, dir)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			if is_nvim_or_tmux_or_zellij(pane) then
				win:perform_action({
					SendKey = { key = key, mods = mods }
				}, pane)
				return
			end
			local handler = ACTION_HANDLERS[action_str]
			if handler then
				local result = handler(win, pane, dir)
				if result then
					win:perform_action(result, pane)
				end
			else
				win:perform_action({
					SendKey = { key = key, mods = mods }
				}, pane)
			end
		end)
	}
end
--------------------------------------------------------------------------------

local keys = {
	-- {key = "s",mods = "LEADER|CTRL",action = wezterm.action {SendString = "\x01"}},

	-- Normal
	create_keybind("SpawnTab", "ALT", "t", "CurrentPaneDomain"),
	create_keybind("smart_split", "ALT", "n"),
	create_keybind("CloseCurrentTab", "ALT", "q"),
	create_keybind("CloseCurrentPane", "ALT", "x"),

	{ key = "T",      mods = "SHIFT|CTRL",   action = act { SpawnTab = "CurrentPaneDomain" } },
	{ key = "W",      mods = "SHIFT|CTRL",   action = act { CloseCurrentTab = { confirm = true } } },
	{ key = "V",      mods = "SHIFT|CTRL",   action = act { PasteFrom = "Clipboard" } },
	{ key = "C",      mods = "SHIFT|CTRL",   action = act { CopyTo = "Clipboard" } },
	{ key = "Tab",    mods = "CTRL",         action = act.ActivateTabRelative(1) },
	{ key = "Tab",    mods = "SHIFT|CTRL",   action = act.ActivateTabRelative(-1) },
	{ key = "Return", mods = "ALT",          action = "ToggleFullScreen" },
	{ key = "F11",    mods = "",             action = "ToggleFullScreen" },

	{ key = "c",      mods = "LEADER",       action = act { SpawnTab = "CurrentPaneDomain" } },
	{ key = "&",      mods = "LEADER",       action = act { CloseCurrentTab = { confirm = false } } },
	{ key = "q",      mods = "LEADER",       action = act { CloseCurrentTab = { confirm = false } } },
	{ key = "x",      mods = "LEADER",       action = act { CloseCurrentPane = { confirm = false } } },
	{ key = 's',      mods = 'LEADER',       action = act.PaneSelect },
	{ key = 'S',      mods = 'SHIFT|LEADER', action = act.PaneSelect { mode = 'SwapWithActive' } },
	{ key = 'w',      mods = 'LEADER',       action = act.ShowTabNavigator },
	{ key = "k",      mods = "LEADER",       action = act.RotatePanes "Clockwise" },

	-- Pane navigation
	create_keybind("ActivatePaneDirection", "ALT", "h", "Left"),
	create_keybind("ActivatePaneDirection", "ALT", "j", "Down"),
	create_keybind("ActivatePaneDirection", "ALT", "k", "Up"),
	create_keybind("ActivatePaneDirection", "ALT", "l", "Right"),

	create_keybind("ActivatePaneDirection", "ALT", "[", "Prev"),
	create_keybind("ActivatePaneDirection", "ALT", "]", "Next"),

	{ key = "a",          mods = "LEADER",   action = act.ActivateKeyTable { name = 'activate_pane', one_shot = false, timeout_milliseconds = 5000 } },

	{ key = 'h',          mods = 'LEADER',   action = wezterm.action_callback(activate_pane_with_dir("Left")) },
	{ key = 'j',          mods = 'LEADER',   action = wezterm.action_callback(activate_pane_with_dir("Down")) },
	{ key = 'k',          mods = 'LEADER',   action = wezterm.action_callback(activate_pane_with_dir("Up")) },
	{ key = 'l',          mods = 'LEADER',   action = wezterm.action_callback(activate_pane_with_dir("Right")) },

	{ key = "UpArrow",    mods = "LEADER",   action = wezterm.action_callback(activate_pane_with_dir("Up")) },
	{ key = "DownArrow",  mods = "LEADER",   action = wezterm.action_callback(activate_pane_with_dir("Down")) },
	{ key = "LeftArrow",  mods = "LEADER",   action = wezterm.action_callback(activate_pane_with_dir("Left")) },
	{ key = "RightArrow", mods = "LEADER",   action = wezterm.action_callback(activate_pane_with_dir("Right")) },

	{ key = "h",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Left" } },
	{ key = "j",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Down" } },
	{ key = "k",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Up" } },
	{ key = "l",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Right" } },

	{ key = "UpArrow",    mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Up" } },
	{ key = "DownArrow",  mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Down" } },
	{ key = "LeftArrow",  mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Left" } },
	{ key = "RightArrow", mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Right" } },

	-- Pane resize
	create_keybind("AdjustPaneSize", "ALT", "LeftArrow", "Left"),
	create_keybind("AdjustPaneSize", "ALT", "RightArrow", "Right"),
	create_keybind("AdjustPaneSize", "ALT", "UpArrow", "Up"),
	create_keybind("AdjustPaneSize", "ALT", "DownArrow", "Down"),

	{ key = 'r',          mods = 'LEADER',         action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false, timeout_milliseconds = 5000 } },

	-- use Multiple keybinds fails because of async, so use action_callback
	{ key = 'H',          mods = 'SHIFT|LEADER',   action = wezterm.action_callback(resize_pane_with_dir("Left")) },
	{ key = 'J',          mods = 'SHIFT|LEADER',   action = wezterm.action_callback(resize_pane_with_dir("Down")) },
	{ key = 'K',          mods = 'SHIFT|LEADER',   action = wezterm.action_callback(resize_pane_with_dir("Up")) },
	{ key = 'L',          mods = 'SHIFT|LEADER',   action = wezterm.action_callback(resize_pane_with_dir("Right")) },

	{ key = "UpArrow",    mods = "SHIFT|LEADER",   action = wezterm.action_callback(resize_pane_with_dir("Up")) },
	{ key = "DownArrow",  mods = "SHIFT|LEADER",   action = wezterm.action_callback(resize_pane_with_dir("Down")) },
	{ key = "LeftArrow",  mods = "SHIFT|LEADER",   action = wezterm.action_callback(resize_pane_with_dir("Left")) },
	{ key = "RightArrow", mods = "SHIFT|LEADER",   action = wezterm.action_callback(resize_pane_with_dir("Right")) },

	{ key = "h",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Left", 1 } } },
	{ key = "l",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Right", 1 } } },
	{ key = "k",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Up", 1 } } },
	{ key = "j",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Down", 1 } } },

	{ key = "UpArrow",    mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Up", 1 } } },
	{ key = "DownArrow",  mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Down", 1 } } },
	{ key = "LeftArrow",  mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Left", 1 } } },
	{ key = "RightArrow", mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Right", 1 } } },

	-- Pane splitting
	{ key = "Enter",      mods = "LEADER",         action = wezterm.action_callback(smart_split_callback) },
	{ key = "Enter",      mods = "ALT|CTRL",       action = wezterm.action_callback(smart_split_callback) },
	{ key = "Enter",      mods = "SHIFT|CTRL",     action = wezterm.action_callback(smart_split_callback) },
	{ key = "-",          mods = "ALT|CTRL",       action = act { SplitVertical = { domain = "CurrentPaneDomain" } } },
	{ key = "\\",         mods = "ALT|CTRL",       action = act { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
	{ key = "-",          mods = "LEADER",         action = act { SplitVertical = { domain = "CurrentPaneDomain" } } },
	{ key = "\\",         mods = "LEADER",         action = act { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
	{ key = "_",          mods = "SHIFT|CTRL",     action = act { SplitVertical = { domain = "CurrentPaneDomain" } } },
	{ key = "|",          mods = "SHIFT|CTRL",     action = act { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
	{ key = "m",          mods = "LEADER",         action = "TogglePaneZoomState" },

	-- Tab navigation
	create_keybind("ActivateTabRelative", "ALT|CTRL", "[", -1),
	create_keybind("ActivateTabRelative", "ALT|CTRL", "]", 1),

	{ key = "A",          mods = "SHIFT|LEADER", action = act.ActivateKeyTable { name = "activate_tab", one_shot = false, timeout_milliseconds = 5000 } },

	{ key = "LeftArrow",  mods = "SHIFT|CTRL",   action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT|CTRL",   action = act.ActivateTabRelative(1) },

	{ key = "n",          mods = "LEADER",       action = wezterm.action_callback(activate_tab_with_dir(1)) },
	{ key = "p",          mods = "LEADER",       action = wezterm.action_callback(activate_tab_with_dir(-1)) },

	{ key = "1",          mods = "LEADER",       action = act { ActivateTab = 0 } },
	{ key = "2",          mods = "LEADER",       action = act { ActivateTab = 1 } },
	{ key = "3",          mods = "LEADER",       action = act { ActivateTab = 2 } },
	{ key = "4",          mods = "LEADER",       action = act { ActivateTab = 3 } },
	{ key = "5",          mods = "LEADER",       action = act { ActivateTab = 4 } },
	{ key = "6",          mods = "LEADER",       action = act { ActivateTab = 5 } },
	{ key = "7",          mods = "LEADER",       action = act { ActivateTab = 6 } },
	{ key = "8",          mods = "LEADER",       action = act { ActivateTab = 7 } },
	{ key = "9",          mods = "LEADER",       action = act { ActivateTab = 8 } },
	{ key = "0",          mods = "LEADER",       action = act { ActivateTab = -1 } },

	create_keybind("ActivateTab", "ALT", "1", 0),
	create_keybind("ActivateTab", "ALT", "2", 1),
	create_keybind("ActivateTab", "ALT", "3", 2),
	create_keybind("ActivateTab", "ALT", "4", 3),
	create_keybind("ActivateTab", "ALT", "5", 4),
	create_keybind("ActivateTab", "ALT", "6", 5),
	create_keybind("ActivateTab", "ALT", "7", 6),
	create_keybind("ActivateTab", "ALT", "8", 7),
	create_keybind("ActivateTab", "ALT", "9", 8),
	create_keybind("ActivateTab", "ALT", "0", -1),

	{ key = "1", mods = "ALT|CTRL", action = act { ActivateTab = 0 } },
	{ key = "2", mods = "ALT|CTRL", action = act { ActivateTab = 1 } },
	{ key = "3", mods = "ALT|CTRL", action = act { ActivateTab = 2 } },
	{ key = "4", mods = "ALT|CTRL", action = act { ActivateTab = 3 } },
	{ key = "5", mods = "ALT|CTRL", action = act { ActivateTab = 4 } },
	{ key = "6", mods = "ALT|CTRL", action = act { ActivateTab = 5 } },
	{ key = "7", mods = "ALT|CTRL", action = act { ActivateTab = 6 } },
	{ key = "8", mods = "ALT|CTRL", action = act { ActivateTab = 7 } },
	{ key = "9", mods = "ALT|CTRL", action = act { ActivateTab = 8 } },
	{ key = "0", mods = "ALT|CTRL", action = act { ActivateTab = -1 } },

	-- Tab movement
	{ key = "R", mods = "LEADER",   action = act.ActivateKeyTable { name = "move_tab", one_shot = false, timeout_milliseconds = 5000 } },
	create_keybind("MoveTabRelative", "SHIFT|ALT", "{", -1),
	create_keybind("MoveTabRelative", "SHIFT|ALT", "}", 1),

	{ key = "UpArrow",   mods = "SHIFT|CTRL",   action = act.MoveTabRelative(-1) },
	{ key = "DownArrow", mods = "SHIFT|CTRL",   action = act.MoveTabRelative(1) },

	{ key = "P",         mods = "SHIFT|LEADER", action = wezterm.action_callback(move_tab_with_dir(-1)) },
	{ key = "N",         mods = "SHIFT|LEADER", action = wezterm.action_callback(move_tab_with_dir(1)) },


	-- other
	{ key = 'S',         mods = 'SHIFT|ALT',    action = act.ShowLauncherArgs { flags = 'FUZZY|TABS|LAUNCH_MENU_ITEMS' }, },
	{ key = 'F9',        mods = 'ALT',          action = act.ShowTabNavigator },
	{ key = 'Space',     mods = 'LEADER',       action = act.ShowLauncher },
	{ key = '/',         mods = 'LEADER',       action = act.ActivateCopyMode },

}

local mouse_bindings = {
	{
		-- right clink select (not wezterm copy mode),copy, and if don't select anything, paste
		-- https://github.com/wez/wezterm/discussions/3541#discussioncomment-5633570
		event = { Down = { streak = 1, button = 'Right' } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({
					PasteFrom = "Clipboard"
				}), pane)
			end
		end)
	},
	-- Change the default click behavior so that it only selects
	-- text and doesn't open hyperlinks
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'NONE',
		-- action = act.CompleteSelection('ClipboardAndPrimarySelection'),
		action = act.Nop
	},
	-- and make CTRL-Click open hyperlinks
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'CTRL',
		action = act.OpenLinkAtMouseCursor,
	},
}

return {
	leader = leader,
	key_tables = key_tables,
	keys = keys,
	mouse_bindings = mouse_bindings,
}
