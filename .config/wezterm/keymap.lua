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
    -- Defines the keys that are active in our resize-pane mode.
    -- Since we're likely to want to make multiple adjustments,
    -- we made the activation one_shot=false. We therefore need
    -- to define a key assignment for getting out of this mode.
    -- 'resize_pane' here corresponds to the name="resize_pane" in
    -- the key assignments above.
    resize_pane = {
        { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
        { key = 'h',          action = act.AdjustPaneSize { 'Left', 1 } },
        { key = 'H',          action = act.AdjustPaneSize { 'Left', 5 } },

        { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
        { key = 'l',          action = act.AdjustPaneSize { 'Right', 1 } },
        { key = 'L',          action = act.AdjustPaneSize { 'Right', 5 } },

        { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'k',          action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'K',          action = act.AdjustPaneSize { 'Up', 5 } },

        { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'j',          action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'J',          action = act.AdjustPaneSize { 'Down', 5 } },

        -- Cancel the mode by pressing escape
        { key = 'Escape',     action = 'PopKeyTable' },
        { key = 'q',          action = 'PopKeyTable' },
        { key = 'Q',          action = 'PopKeyTable' }
    },
    -- Defines the keys that are active in our activate-pane mode.
    -- 'activate_pane' here corresponds to the name="activate_pane" in
    -- the key assignments above.
    activate_pane = {
        { key = 'LeftArrow',  action = act.ActivatePaneDirection 'Left' },
        { key = 'h',          action = act.ActivatePaneDirection 'Left' },

        { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
        { key = 'l',          action = act.ActivatePaneDirection 'Right' },

        { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
        { key = 'k',          action = act.ActivatePaneDirection 'Up' },

        { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },
        { key = 'j',          action = act.ActivatePaneDirection 'Down' },

        -- Cancel the mode by pressing escape
        { key = 'Escape',     action = 'PopKeyTable' },
        { key = 'q',          action = 'PopKeyTable' },
        { key = 'Q',          action = 'PopKeyTable' }
    },
}

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

local function smart_split_callback(window, pane)
    local dim = pane:get_dimensions()
    if dim.pixel_height > dim.pixel_width then
        window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
    else
        window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
    end
end

local function activate_pane_left(window, pane)
    local tab = window:mux_window():active_tab()
    if tab:get_pane_direction("Left") ~= nil then
        window:perform_action(wezterm.action.ActivatePaneDirection("Left"), pane)
    else
        window:perform_action(wezterm.action.ActivateTabRelative(-1), pane)
    end
end
local function activate_pane_right(window, pane)
    local tab = window:mux_window():active_tab()
    if tab:get_pane_direction("Right") ~= nil then
        window:perform_action(wezterm.action.ActivatePaneDirection("Right"), pane)
    else
        window:perform_action(wezterm.action.ActivateTabRelative(1), pane)
    end
end

local function activate_pane_prev(window, pane)
    local tab = window:mux_window():active_tab()
    local panes = tab:panes_with_info()
    local max_panes = 0
    for _, p in ipairs(panes) do
        if p.pane_index > max_panes then
            max_panes = p.pane_index
        end
    end
    local max_tabs = 0
    for _, t in ipairs(window:mux_window():tabs()) do
        if t.tab_index > max_tabs then
            max_tabs = t.tab_index
        end
    end


    if max_tabs == 1 then
        window:perform_action(wezterm.action.ActivatePaneDirection("Prev"), pane)
    else
        if pane.pane_index ~= 0 then
            window:perform_action(wezterm.action.ActivatePaneDirection("Prev"), pane)
        else
            window:perform_action(wezterm.action.ActivateTabRelative(-1), pane)
        end
    end
end
local smart_split = wezterm.action_callback(smart_split_callback)

local function create_keybind(action_str, mods, key, dir)
    return {
        key = key,
        mods = mods,
        action = wezterm.action_callback(function(win, pane)
            if is_nvim_or_tmux_or_zellij(pane) then
                win:perform_action({
                    SendKey = { key = key, mods = mods }
                }, pane)
            elseif action_str == "AdjustPaneSize" then
                win:perform_action({
                    AdjustPaneSize = { dir, 5 }
                }, pane)
            elseif action_str == "ActivatePaneDirection" then
                local panes = pane:tab():panes_with_info()
                local is_zoomed = false
                for _, p in ipairs(panes) do
                    if p.is_zoomed then
                        is_zoomed = true
                    end
                end

                if is_zoomed then
                    dir = dir == "Up" or dir == "Right" and "Next" or "Prev"
                end

                if dir == "Left" then
                    activate_pane_left(win, pane)
                elseif dir == "Right" then
                    activate_pane_right(win, pane)
                end
                win:perform_action({
                    ActivatePaneDirection = dir
                }, pane)
                win:perform_action({
                    SetPaneZoomState = is_zoomed
                }, pane)
            elseif action_str == "ActivateTab" then
                win:perform_action(
                    wezterm.action.ActivateTab(dir),
                    pane
                )
            elseif action_str == "ActivateTabRelative" then
                win:perform_action(
                    wezterm.action.ActivateTabRelative(dir),
                    pane
                )
            elseif action_str == "SpawnTab" then
                win:perform_action(
                    wezterm.action.SpawnTab(dir),
                    pane
                )
            elseif action_str == "CloseCurrentTab" then
                win:perform_action(
                    wezterm.action.CloseCurrentTab { confirm = true },
                    pane
                )
            elseif action_str == "CloseCurrentPane" then
                win:perform_action(
                    wezterm.action.CloseCurrentPane { confirm = true },
                    pane
                )
            elseif action_str == "smart_split" then
                smart_split_callback(win, pane)
            else
                win:perform_action({
                    SendKey = { key = key, mods = mods }
                }, pane)
            end
        end)
    }
end

local keys = {
    -- {key = "s",mods = "LEADER|CTRL",action = wezterm.action {SendString = "\x01"}},
    {
        key = 'r',
        mods = 'LEADER',
        action = act.ActivateKeyTable {
            name = 'resize_pane',
            one_shot = false,
            timeout_milliseconds = 5000
        }
    },

    -- Normal
    create_keybind("SpawnTab", "ALT", "t", "CurrentPaneDomain"),
    create_keybind("smart_split", "ALT", "n"),
    create_keybind("CloseCurrentTab", "ALT", "q"),
    create_keybind("CloseCurrentPane", "ALT", "x"),

    { key = "t", mods = "SHIFT|CTRL",   action = act { SpawnTab = "CurrentPaneDomain" } },
    { key = "w", mods = "SHIFT|CTRL",   action = act { CloseCurrentTab = { confirm = true } } },
    { key = "c", mods = "LEADER",       action = act { SpawnTab = "CurrentPaneDomain" } },
    { key = "&", mods = "LEADER",       action = act { CloseCurrentTab = { confirm = false } } },
    { key = "q", mods = "LEADER",       action = act { CloseCurrentTab = { confirm = false } } },
    { key = "x", mods = "LEADER",       action = act { CloseCurrentPane = { confirm = false } } },
    { key = 's', mods = 'LEADER',       action = act.PaneSelect },
    { key = 's', mods = 'SHIFT|LEADER', action = act.PaneSelect { mode = 'SwapWithActive' } },
    { key = 'w', mods = 'LEADER',       action = act.ShowTabNavigator },
    { key = "k", mods = "LEADER",       action = act.RotatePanes "Clockwise" },


    -- Pane navigation
    create_keybind("ActivatePaneDirection", "ALT", "h", "Left"),
    create_keybind("ActivatePaneDirection", "ALT", "j", "Down"),
    create_keybind("ActivatePaneDirection", "ALT", "k", "Up"),
    create_keybind("ActivatePaneDirection", "ALT", "l", "Right"),

    create_keybind("ActivatePaneDirection", "ALT", "[", "Prev"),
    create_keybind("ActivatePaneDirection", "ALT", "]", "Next"),

    { key = 'h',          mods = 'LEADER',   action = act.ActivateKeyTable { name = 'activate_pane', one_shot = false, timeout_milliseconds = 600 } },
    { key = 'j',          mods = 'LEADER',   action = act.ActivateKeyTable { name = 'activate_pane', one_shot = false, timeout_milliseconds = 600 } },
    { key = 'k',          mods = 'LEADER',   action = act.ActivateKeyTable { name = 'activate_pane', one_shot = false, timeout_milliseconds = 600 } },
    { key = 'l',          mods = 'LEADER',   action = act.ActivateKeyTable { name = 'activate_pane', one_shot = false, timeout_milliseconds = 600 } },

    { key = "h",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Left" } },
    { key = "j",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Down" } },
    { key = "k",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Up" } },
    { key = "l",          mods = "ALT|CTRL", action = act { ActivatePaneDirection = "Right" } },

    { key = "UpArrow",    mods = "LEADER",   action = act { ActivatePaneDirection = "Up" } },
    { key = "DownArrow",  mods = "LEADER",   action = act { ActivatePaneDirection = "Down" } },
    { key = "LeftArrow",  mods = "LEADER",   action = act { ActivatePaneDirection = "Left" } },
    { key = "RightArrow", mods = "LEADER",   action = act { ActivatePaneDirection = "Right" } },

    -- Pane adjust
    create_keybind("AdjustPaneSize", "ALT", "LeftArrow", "Left"),
    create_keybind("AdjustPaneSize", "ALT", "RightArrow", "Right"),
    create_keybind("AdjustPaneSize", "ALT", "UpArrow", "Up"),
    create_keybind("AdjustPaneSize", "ALT", "DownArrow", "Down"),

    { key = "h",          mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Left", 40, }, } },
    { key = "l",          mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Right", 40 } } },
    { key = "k",          mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Up", 40 } } },
    { key = "j",          mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Down", 40 } } },

    { key = "UpArrow",    mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Up", 40 } } },
    { key = "DownArrow",  mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Down", 40 } } },
    { key = "LeftArrow",  mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Left", 40 } } },
    { key = "RightArrow", mods = "SHIFT|LEADER",   action = act { AdjustPaneSize = { "Right", 40 } } },

    { key = "h",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Left", 1 } } },
    { key = "l",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Right", 1 } } },
    { key = "k",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Up", 1 } } },
    { key = "j",          mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Down", 1 } } },

    { key = "UpArrow",    mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Up", 1 } } },
    { key = "DownArrow",  mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Down", 1 } } },
    { key = "LeftArrow",  mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Left", 1 } } },
    { key = "RightArrow", mods = "SHIFT|ALT|CTRL", action = act { AdjustPaneSize = { "Right", 1 } } },

    -- Pane splitting
    { key = "Enter",      mods = "LEADER",         action = smart_split },
    { key = "Enter",      mods = "ALT|CTRL",       action = smart_split },
    { key = "Enter",      mods = "SHIFT|CTRL",     action = smart_split },
    { key = "-",          mods = "ALT|CTRL",       action = act { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "\\",         mods = "ALT|CTRL",       action = act { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
    { key = "-",          mods = "LEADER",         action = act { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "\\",         mods = "LEADER",         action = act { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
    { key = "m",          mods = "LEADER",         action = "TogglePaneZoomState" },

    -- Tab navigation
    create_keybind("ActivateTabRelative", "ALT|CTRL", "[", -1),
    create_keybind("ActivateTabRelative", "ALT|CTRL", "]", 1),
    { key = 'Space',      mods = 'LEADER',         action = act.ShowLauncher },
    { key = 'S',          mods = 'SHIFT|ALT',      action = act.ShowLauncherArgs { flags = 'FUZZY|TABS|LAUNCH_MENU_ITEMS' }, },
    { key = 'F9',         mods = 'ALT',            action = act.ShowTabNavigator },

    { key = "LeftArrow",  mods = "SHIFT|CTRL",     action = act.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "SHIFT|CTRL",     action = act.ActivateTabRelative(1) },

    { key = "Tab",        mods = "CTRL",           action = act.ActivateTabRelative(1) },
    { key = "Tab",        mods = "SHIFT|CTRL",     action = act.ActivateTabRelative(-1) },


    { key = "]", mods = "LEADER",   action = act.ActivateTabRelative(1) },
    { key = "[", mods = "LEADER",   action = act.ActivateTabRelative(-1) },

    { key = "n", mods = "LEADER",   action = act.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER",   action = act.ActivateTabRelative(-1) },
    { key = "n", mods = "ALT|CTRL", action = act.ActivateTabRelative(1) },
    { key = "p", mods = "ALT|CTRL", action = act.ActivateTabRelative(-1) },

    { key = "1", mods = "LEADER",   action = act { ActivateTab = 0 } },
    { key = "2", mods = "LEADER",   action = act { ActivateTab = 1 } },
    { key = "3", mods = "LEADER",   action = act { ActivateTab = 2 } },
    { key = "4", mods = "LEADER",   action = act { ActivateTab = 3 } },
    { key = "5", mods = "LEADER",   action = act { ActivateTab = 4 } },
    { key = "6", mods = "LEADER",   action = act { ActivateTab = 5 } },
    { key = "7", mods = "LEADER",   action = act { ActivateTab = 6 } },
    { key = "8", mods = "LEADER",   action = act { ActivateTab = 7 } },
    { key = "9", mods = "LEADER",   action = act { ActivateTab = 8 } },
    { key = "0", mods = "LEADER",   action = act { ActivateTab = -1 } },

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

    { key = "1",      mods = "ALT|CTRL",   action = act { ActivateTab = 0 } },
    { key = "2",      mods = "ALT|CTRL",   action = act { ActivateTab = 1 } },
    { key = "3",      mods = "ALT|CTRL",   action = act { ActivateTab = 2 } },
    { key = "4",      mods = "ALT|CTRL",   action = act { ActivateTab = 3 } },
    { key = "5",      mods = "ALT|CTRL",   action = act { ActivateTab = 4 } },
    { key = "6",      mods = "ALT|CTRL",   action = act { ActivateTab = 5 } },
    { key = "7",      mods = "ALT|CTRL",   action = act { ActivateTab = 6 } },
    { key = "8",      mods = "ALT|CTRL",   action = act { ActivateTab = 7 } },
    { key = "9",      mods = "ALT|CTRL",   action = act { ActivateTab = 8 } },
    { key = "0",      mods = "ALT|CTRL",   action = act { ActivateTab = -1 } },

    -- other
    { key = "Return", mods = "ALT",        action = "ToggleFullScreen" },
    { key = "F11",    mods = "",           action = "ToggleFullScreen" },
    { key = '/',      mods = 'LEADER',     action = act.ActivateCopyMode },
    -- copy and paste
    { key = "v",      mods = "SHIFT|CTRL", action = act { PasteFrom = "Clipboard" } },
    { key = "c",      mods = "SHIFT|CTRL", action = act { CopyTo = "Clipboard" } },
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
