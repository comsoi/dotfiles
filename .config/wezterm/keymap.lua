local wezterm = require("wezterm")
local act = wezterm.action

-- key bindings
local leader = {
-- win + alt + space
    key = 'Space',
    mods = 'SUPER|ALT'
}


local key_tables = {
-- Defines the keys that are active in our resize-pane mode.
-- Since we're likely to want to make multiple adjustments,
-- we made the activation one_shot=false. We therefore need
-- to define a key assignment for getting out of this mode.
-- 'resize_pane' here corresponds to the name="resize_pane" in
-- the key assignments above.
    resize_pane = {
        { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 1 } },
        { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
        { key = 'H', action = act.AdjustPaneSize { 'Left', 5 } },

        { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
        { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
        { key = 'L', action = act.AdjustPaneSize { 'Right', 5 } },

        { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'K', action = act.AdjustPaneSize { 'Up', 5 } },

        { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'J', action = act.AdjustPaneSize { 'Down', 5 } },

        -- Cancel the mode by pressing escape
        { key = 'Escape', action = 'PopKeyTable' },
        { key = 'q', action = 'PopKeyTable' },
        { key = 'Q', action = 'PopKeyTable' }
    },
    -- Defines the keys that are active in our activate-pane mode.
    -- 'activate_pane' here corresponds to the name="activate_pane" in
    -- the key assignments above.
    activate_pane = {
        { key = 'LeftArrow', action = act.ActivatePaneDirection 'Left' },
        { key = 'h', action = act.ActivatePaneDirection 'Left' },

        { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
        { key = 'l', action = act.ActivatePaneDirection 'Right' },

        { key = 'UpArrow', action = act.ActivatePaneDirection 'Up' },
        { key = 'k', action = act.ActivatePaneDirection 'Up' },

        { key = 'DownArrow', action = act.ActivatePaneDirection 'Down' },
        { key = 'j', action = act.ActivatePaneDirection 'Down' },

        -- Cancel the mode by pressing escape
        { key = 'Escape', action = 'PopKeyTable' },
        { key = 'q', action = 'PopKeyTable' },
        { key = 'Q', action = 'PopKeyTable' }
    },
}


local keys = {
    -- {key = "s",mods = "LEADER|CTRL",action = wezterm.action {SendString = "\x01"}},

    -- Pane navigation
    --  followed by 'r' will put us in resize-pane mode
    -- until we cancel that mode with 'q' or 'Escape', or
    -- until the timeout_milliseconds has elapsed.
    {
        key = 'r',
        mods = 'LEADER',
        action = act.ActivateKeyTable {
            name = 'resize_pane',
            one_shot = false,
            timeout_milliseconds = 5000
        }
    },
    -- followed by 'a' will put us in activate-pane
    {
    key = 'a',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
            name = 'activate_pane',
            one_shot = false,
            timeout_milliseconds = 450,
        },
    },
    {key = "h", mods = "LEADER", action = wezterm.action{ActivatePaneDirection = "Left"}},
    {key = "j", mods = "LEADER", action = wezterm.action{ActivatePaneDirection = "Down"}},
    {key = "k", mods = "LEADER", action = wezterm.action{ActivatePaneDirection = "Up"}},
    {key = "l", mods = "LEADER", action = wezterm.action{ActivatePaneDirection = "Right"}},
    {key = 's', mods = 'LEADER', action = wezterm.action.PaneSelect{mode = 'SwapWithActive'}},
    {key = "-", mods = "LEADER", action = act{SplitVertical = {domain = "CurrentPaneDomain"}}},
    {key = "\\", mods = "LEADER", action = act{SplitHorizontal = {domain = "CurrentPaneDomain"}}},
    {key = "m", mods = "LEADER", action = "TogglePaneZoomState"},
    {key = "c", mods = "LEADER", action = act{SpawnTab = "CurrentPaneDomain"}},
    -- Tab navigation
    {key = 'S', mods = 'SHIFT|ALT', action =act.ShowLauncherArgs{flags = 'FUZZY|TABS|LAUNCH_MENU_ITEMS'},},
    {key = 'F9', mods = 'ALT', action = wezterm.action.ShowTabNavigator},
    {key = 'F10', mods = 'ALT', action = wezterm.action.ShowLauncher},
    {key = 'z' , mods = 'LEADER', action = wezterm.action.ShowLauncher},
    {key="n", mods="LEADER", action = act.ActivateTabRelative(1)},
    {key="p", mods="LEADER", action = act.ActivateTabRelative(-1)},
    {key = "1", mods = "LEADER", action = wezterm.action{ActivateTab = 0}},
    {key = "2", mods = "LEADER", action = wezterm.action{ActivateTab = 1}},
    {key = "3", mods = "LEADER", action = wezterm.action{ActivateTab = 2}},
    {key = "4", mods = "LEADER", action = wezterm.action{ActivateTab = 3}},
    {key = "5", mods = "LEADER", action = wezterm.action{ActivateTab = 4}},
    {key = "6", mods = "LEADER", action = wezterm.action{ActivateTab = 5}},
    {key = "7", mods = "LEADER", action = wezterm.action{ActivateTab = 6}},
    {key = "8", mods = "LEADER", action = wezterm.action{ActivateTab = 7}},
    {key = "9", mods = "LEADER", action = wezterm.action{ActivateTab = 8}},
    {key = "1", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 0}},
    {key = "2", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 1}},
    {key = "3", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 2}},
    {key = "4", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 3}},
    {key = "5", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 4}},
    {key = "6", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 5}},
    {key = "7", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 6}},
    {key = "8", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 7}},
    {key = "9", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 8}},
    {key = "0", mods = "ALT|CTRL", action = wezterm.action{ActivateTab = 9}},
    {key = "&", mods = "LEADER|SHIFT", action = wezterm.action{CloseCurrentTab = {confirm = true}}},
    {key = "x", mods = "LEADER", action = wezterm.action{CloseCurrentPane = {confirm = true}}},
    -- rotate panes
    -- show the pane selection mode, but have it swap the active and selected panes
    {mods = "LEADER", key = "Space", action = wezterm.action.RotatePanes "Clockwise"},
    -- other
    -- full screen
    -- alt Enter | F11
    {key = "F11", mods = "", action = "ToggleFullScreen"},
    -- copy and paste
    {key = "v", mods = "SHIFT|CTRL", action = wezterm.action{PasteFrom = "Clipboard"}},
    {key = "c", mods = "SHIFT|CTRL", action = wezterm.action{CopyTo = "Clipboard"}},
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
