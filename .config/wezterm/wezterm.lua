local wezterm = require("wezterm")
local act = wezterm.action
local launch_menu = {}
local default_prog = {}
-- global env vars
local set_environment_variables = {
    -- CHERE_INVOKING = "1"
}
local term = "xterm-256color"
local wsl_domains = wezterm.default_wsl_domains()

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    term = "xterm-256color"
    set_environment_variables = {
        -- CHERE_INVOKING = "1"
    }
    -- term = "wezterm"
    default_prog = {"nu.exe"}
    table.insert(launch_menu, {
        label = "Zsh",
        args = {"D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l"}
    })
    table.insert(launch_menu, {
        label = "PowerShell",
        args = {"pwsh.exe", "-NoLogo"}
    })
    table.insert(launch_menu, {
        label = "cmder",
        args = {"cmd.exe", "/k", "title Cmder/Cmd & ", "%CMDER_ROOT%\\vendor\\init.bat"}
    })
    table.insert(launch_menu, {
        label = "nushell",
        args = {"D:/Scoop/apps/nu/current/nu.exe"}
    })
    table.insert(launch_menu, {
        label = "wsl:ubuntu-20.04",
        args = {"wezterm.exe", "ssh", "ubuntu@127.0.0.1:2222"}
    })

    -- Find installed visual studio version(s) and add their compilation
    -- environment command prompts to the menu
    for _, vsvers in ipairs(wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files (x86)')) do
        local year = vsvers:gsub('Microsoft Visual Studio/', '')
        table.insert(launch_menu, {
            label = 'x64 Native Tools VS ' .. year,
            args = {'cmd.exe', '/k',
                    'C:/Program Files (x86)/' .. vsvers .. '/BuildTools/VC/Auxiliary/Build/vcvars64.bat'}
        })
    end

elseif wezterm.target_triple == 'x86_64-unknown-linux-gnu' then
    table.insert(launch_menu, {
        label = 'Bash',
        args = {'bash', '-l'}
    })
    default_prog = {'bash', '-l'}
else
    table.insert(launch_menu, {
        label = "bash",
        args = {"bash", "-l"}
    })
    table.insert(launch_menu, {
        label = "fish",
        args = {"zsh", "-l"}
    })
    table.insert(launch_menu, {
        label = "fish",
        args = {"fish", "-l"}
    })
    default_prog = {'zsh', '-l'}
end

-- Tab title
function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane

    local index = ""
    if #tabs > 1 then
        index = string.format("%d: ", tab.tab_index + 1)
    end

    local process = basename(pane.foreground_process_name)

    return {{
        Text = ' ' .. index .. process .. ' '
    }}
end)

-- Scrollbar hidden
-- https://github.com/wez/wezterm/issues/4331
wezterm.on("update-status", function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.colors then
        overrides.colors = {}
    end
    -- if pane:is_alt_screen_active() then
    --     overrides.colors.scrollbar_thumb = "transparent"
    -- else
    --     overrides.colors.scrollbar_thumb = nil
    -- end
    overrides.colors.scrollbar_thumb = "transparent"
    window:set_config_overrides(overrides)
end)

-- Show which key table is active in the status area
wezterm.on('update-right-status', function(window, pane)
    local name = window:active_key_table()
    if name then
        name = 'TABLE: ' .. name
    end
    window:set_right_status(name or '')
end)


local function is_vim(pane)
    -- this is set by the plugin, and unset on ExitPre in Neovim
    return pane:get_user_vars().IS_NVIM == 'true' or pane:get_user_vars().IS_VIM == 'true'
end

local direction_keys = {
    Left = 'h',
    Down = 'j',
    Up = 'k',
    Right = 'l',
    -- reverse lookup
    h = 'Left',
    j = 'Down',
    k = 'Up',
    l = 'Right'
}

local function split_nav(resize_or_move, key)
    return {
        key = key,
        mods = resize_or_move == 'resize' and 'META' or 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            if is_vim(pane) then
                -- pass the keys through to vim/nvim
                win:perform_action(wezterm.action.SendKey {
                    key = key,
                    mods = resize_or_move == 'resize' and 'META' or 'CTRL'
                }, pane)
            else
                if resize_or_move == 'resize' then
                    win:perform_action(wezterm.action.AdjustPaneSize {direction_keys[key], 3}, pane)
                else
                    win:perform_action(wezterm.action.ActivatePaneDirection {direction_keys[key]}, pane)
                end
            end
        end)
    }
end

local config = {
    check_for_updates = false,

    initial_cols = 110,
    initial_rows = 35,

    audible_bell = "Disabled",

    -- 样式
    default_cursor_style = "BlinkingBar",
    color_scheme = 'Dracula (Official)',
    -- windows
    window_decorations = "RESIZE",
    window_background_opacity = 0.9,
    window_padding = {
        left = 20,
        right = 20,
        top = 20,
        bottom = 5
    },
    -- Tab bar
    enable_tab_bar = true,
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    show_tab_index_in_tab_bar = true,
    tab_max_width = 25,
    tab_bar_at_bottom = false,
    -- Fonts
    font_size = 13.0,
    -- line_height = 1.2,
    font = wezterm.font_with_fallback {'Fira Code', {
        family = 'Microsoft YaHei',
        scale = 1
    }},
    -- text_background_opacity = 0.9,

    enable_scroll_bar = true,
    inactive_pane_hsb = {
        hue = 1.0,
        saturation = 1.0,
        brightness = 1.0
    },
    launch_menu = launch_menu,
    term = term,
    default_prog = default_prog,



    set_environment_variables = set_environment_variables,
    wsl_domains = wsl_domains
    -- default_domain = "WSL:ubuntu-18.04",
}

config.unix_domains = {{
    name = 'wsl',
    -- Override the default path to match the default on the host win32
    -- filesystem.  This will allow the host to connect into the WSL
    -- container.
    socket_path = '/mnt/c/Users/USERNAME/.local/share/wezterm/sock',
    -- NTFS permissions will always be "wrong", so skip that check
    skip_permissions_check = true
}}
    -- key bindings
config.leader = {
-- win + alt + space
    key = 'Space',
    mods = 'SUPER|ALT'
}
config.disable_default_key_bindings = false

config.key_tables = {
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
config.keys = {
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
{key = 'F9', mods = 'ALT', action = wezterm.action.ShowTabNavigator},
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
-- right clink select (not wezterm copy mode),copy, and if don't select anything, paste
-- https://github.com/wez/wezterm/discussions/3541#discussioncomment-5633570
config.mouse_bindings = {{
    event = {
        Down = {
            streak = 1,
            button = "Right"
        }
    },
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
}}



return config
