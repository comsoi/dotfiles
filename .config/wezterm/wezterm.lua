local wezterm = require("wezterm")
local launch_menu = {}
local default_prog = {}
local set_environment_variables = {CHERE_INVOKING= "1"}
local term = "xterm-256color"
local wsl_domains = wezterm.default_wsl_domains()

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    term = "xterm-256color"
    -- term = "wezterm"
    default_prog = {"nu.exe"}
    table.insert(launch_menu, {
        label = "Zsh",
        args = {"D:/Scoop/apps/git/current/usr/bin/zsh.exe","-l"}
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
        args = {"nu.exe"}
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

-- Title
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
    initial_cols = 100,
    initial_rows = 28,

    audible_bell = "Disabled",
    check_for_updates = false,
    -- 主题
    color_scheme = 'Dracula (Official)',
    enable_scroll_bar = true,
    inactive_pane_hsb = {
        hue = 1.0,
        saturation = 1.0,
        brightness = 1.0
    },
    launch_menu = launch_menu,
    term = term,
    default_prog = default_prog,
    font_size = 11.0,
    leader = {
        key = "a",
        mods = "CTRL"
    },
    disable_default_key_bindings = false,
    -- Tab bar
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = false,
    show_tab_index_in_tab_bar = true,
    tab_bar_at_bottom = true,
    tab_max_width = 25,
    keys = { -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    {
        key = 'F9',
        mods = 'ALT',
        action = wezterm.action.ShowTabNavigator
    }, {
        key = "a",
        mods = "LEADER|CTRL",
        action = wezterm.action {
            SendString = "\x01"
        }
    }, {
        key = "-",
        mods = "LEADER",
        action = wezterm.action {
            SplitVertical = {
                domain = "CurrentPaneDomain"
            }
        }
    }, {
        key = "\\",
        mods = "LEADER",
        action = wezterm.action {
            SplitHorizontal = {
                domain = "CurrentPaneDomain"
            }
        }
    }, {
        key = "m",
        mods = "LEADER",
        action = "TogglePaneZoomState"
    }, {
        key = "c",
        mods = "LEADER",
        action = wezterm.action {
            SpawnTab = "CurrentPaneDomain"
        }
    }, {
        key = "h",
        mods = "LEADER",
        action = wezterm.action {
            ActivatePaneDirection = "Left"
        }
    }, {
        key = "j",
        mods = "LEADER",
        action = wezterm.action {
            ActivatePaneDirection = "Down"
        }
    }, {
        key = "k",
        mods = "LEADER",
        action = wezterm.action {
            ActivatePaneDirection = "Up"
        }
    }, {
        key = "l",
        mods = "LEADER",
        action = wezterm.action {
            ActivatePaneDirection = "Right"
        }
    }, {
        key = "H",
        mods = "LEADER|SHIFT",
        action = wezterm.action {
            AdjustPaneSize = {"Left", 5}
        }
    }, {
        key = "J",
        mods = "LEADER|SHIFT",
        action = wezterm.action {
            AdjustPaneSize = {"Down", 5}
        }
    }, {
        key = "K",
        mods = "LEADER|SHIFT",
        action = wezterm.action {
            AdjustPaneSize = {"Up", 5}
        }
    }, {
        key = "L",
        mods = "LEADER|SHIFT",
        action = wezterm.action {
            AdjustPaneSize = {"Right", 5}
        }
    }, {
        key = "1",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 0
        }
    }, {
        key = "2",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 1
        }
    }, {
        key = "3",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 2
        }
    }, {
        key = "4",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 3
        }
    }, {
        key = "5",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 4
        }
    }, {
        key = "6",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 5
        }
    }, {
        key = "7",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 6
        }
    }, {
        key = "8",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 7
        }
    }, {
        key = "9",
        mods = "LEADER",
        action = wezterm.action {
            ActivateTab = 8
        }
    }, {
        key = "&",
        mods = "LEADER|SHIFT",
        action = wezterm.action {
            CloseCurrentTab = {
                confirm = true
            }
        }
    }, {
        key = "x",
        mods = "LEADER",
        action = wezterm.action {
            CloseCurrentPane = {
                confirm = true
            }
        }
    }, -- rotate panes
    {
        mods = "LEADER",
        key = "Space",
        action = wezterm.action.RotatePanes "Clockwise"
    }, -- show the pane selection mode, but have it swap the active and selected panes
    {
        mods = 'LEADER',
        key = '0',
        action = wezterm.action.PaneSelect {
            mode = 'SwapWithActive'
        }
    }, {
        key = "F11",
        mods = "",
        action = "ToggleFullScreen"
    }, {
        key = "v",
        mods = "SHIFT|CTRL",
        action = wezterm.action.PasteFrom 'Clipboard'
    }, {
        key = "c",
        mods = "SHIFT|CTRL",
        action = wezterm.action.CopyTo 'Clipboard'
    }},

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

return config
