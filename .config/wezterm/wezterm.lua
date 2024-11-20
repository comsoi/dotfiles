local wezterm = require("wezterm")
local keymap_config = require("keymap")
local cmd_abbr = require("cmd_abbr")

local launch_menu = {}
local default_prog = {}

-- global env vars
local set_environment_variables_windows = {}
local set_environment_variables_linux = {}

function scheme_for_appearance(appearance)
    if appearance:find "Dark" then
        return "Catppuccin Frappe"
    else
        return "Catppuccin Latte"
    end
end

local config = {
    check_for_updates = false,
    enable_wayland = false,
    front_end = "WebGpu",
    max_fps = 165,
    enable_kitty_keyboard = true,
    disable_default_key_bindings = true,
    -- initial_cols = 110,
    -- initial_rows = 35,
    audible_bell = "Disabled",
    -- cursor style
    default_cursor_style = "BlinkingBar",
    -- color_scheme
    -- 'Catppuccin Frappe'
    -- 'Catppuccin Latte'
    -- 'Catppuccin Mocha',
    color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
    -- window
    -- RESIZE | MACOS_FORCE_DISABLE_SHADOW | INTEGRATED_BUTTONS | TITLE
    window_decorations = "INTEGRATED_BUTTONS|RESIZE",
    window_background_opacity = 0.75,
    text_background_opacity = 1,
    adjust_window_size_when_changing_font_size = false,
    window_padding = {
        left = 20,
        right = 20,
        top = 10,
        bottom = 0
    },
    -- Tab bar
    enable_tab_bar = true,
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    show_tab_index_in_tab_bar = true,
    tab_max_width = 35, -- +7
    tab_bar_at_bottom = false,
    -- Fonts
    font_size = 13.0,
    font = wezterm.font_with_fallback{
        'Fira Code',
        {
            family = 'Microsoft YaHei',
            scale = 1
        },
        'PingFang SC',
        'Symbols Nerd Font',
        'Segoe UI Emoji',
        'Noto Emoji',
        'Noto Color Emoji',
    },
    -- misc
    enable_scroll_bar = true,
    inactive_pane_hsb = {
        hue = 1.0,
        saturation = 1.0,
        brightness = 1.0
    }
}



-- Tab bar
local COLORS = {
  leading_bg          = 'rgba(35, 38, 52, 1.0)',
  leading_fg          = 'rgba(165, 173, 206, 1.0)',
  background_inactive = 'rgba(35, 38, 52, 1.0)',
  foreground_inactive = 'rgba(165, 173, 206, 1.0)',
  background_active   = 'rgba(114, 135, 253, 1.0)',
  foreground_active   = 'rgba(255, 255, 255, 1.0)',
  background_hover    = 'rgba(140, 170, 238, 1.0)',
  foreground_hover    = 'rgba(65, 69, 89, 1.0)',
  new_tab_bg          = 'rgba(140, 170, 238, 1.0)',
  new_tab_fg          = 'rgba(255, 255, 255, 1.0)',
}

local function adjust_alpha(color, new_alpha)
    -- 提取原始的 r, g, b 值
    local r, g, b = color:match('rgba%((%d+),%s*(%d+),%s*(%d+),%s*[%d%.]+%)')
    -- 使用新的透明度重新格式化颜色
    return string.format("rgba(%s, %s, %s, %.2f)", r, g, b, new_alpha)
end

local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function tab_title(tab_info)
    local title = tab_info.tab_title
    if title and #title > 0 then
        return cmd_abbr.abbreviate_title(title)
    else
        return cmd_abbr.abbreviate_title(tab_info.active_pane.title)
    end
end

-- Tab format with colors
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local leading_bg = COLORS.leading_bg
    local leading_fg = COLORS.leading_fg
    local background = COLORS.background_inactive
    local foreground = COLORS.foreground_inactive

    if tab.is_active then
        background = COLORS.background_active
        foreground = COLORS.foreground_active
    elseif hover then
        background = COLORS.background_hover
        foreground = COLORS.foreground_hover
    end
    local text_right_arrow_fg = adjust_alpha(background, 0.75)
    local text_right_arrow_bg = adjust_alpha(leading_bg, 1)
    local text_left_arrow_fg = adjust_alpha(leading_bg, 0.75)
    local text_left_arrow_bg = adjust_alpha(background, 1)
    local title = tab_title(tab)
    local pane = tab.active_pane
    -- title = pane.pane_index
    -- 确保标题适合可用空间，并保留边缘显示的空间
    local index = ""

    if #tabs > 1 then
        index = string.format("%d ", tab.tab_index + 1)
    end

    return {
        { Attribute = { Italic = false } },
        { Attribute = { Intensity = hover and "Bold" or "Normal" } },
        { Background = { Color = leading_bg } },
        { Foreground = { Color = leading_fg } },

        { Background = { Color = text_left_arrow_bg } },
        { Foreground = { Color = text_left_arrow_fg } },
        { Text = SOLID_RIGHT_ARROW },

        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = " " .. index .. title .. " " },

        { Background = { Color = text_right_arrow_bg } },
        { Foreground = { Color = text_right_arrow_fg } },
        { Text = SOLID_RIGHT_ARROW },
    }
end)

config.colors = {
    tab_bar = {
        -- text_background_opacity = 1.0,
        -- background = 'rgba(0, 0, 0, 0.0)',
    },
}

config.window_frame = {
    font_size = 8.0,
}

config.tab_bar_style = {
    new_tab = wezterm.format{
        { Background = { Color = COLORS.new_tab_bg } },
        { Foreground = { Color = COLORS.leading_bg } },
        { Text = SOLID_RIGHT_ARROW },
        { Background = { Color = COLORS.new_tab_bg } },
        { Foreground = { Color = COLORS.new_tab_fg } },
        { Text = ' + ' },
        { Background = { Color = COLORS.leading_bg } },
        { Foreground = { Color = COLORS.new_tab_bg } },
        { Text = SOLID_RIGHT_ARROW },
    },
    new_tab_hover = wezterm.format{
        { Attribute = { Italic = false } },
        { Attribute = { Intensity = 'Bold' } },
        { Background = { Color = COLORS.leading_bg } },
        { Foreground = { Color = COLORS.leading_bg } },
        { Text = SOLID_RIGHT_ARROW },
        { Background = { Color = COLORS.leading_bg } },
        { Foreground = { Color = COLORS.foreground_inactive } },
        { Text = ' + ' },
        { Background = { Color = COLORS.leading_bg } },
        { Foreground = { Color = COLORS.leading_bg } },
        { Text = SOLID_RIGHT_ARROW },
    },
}


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


if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
    config.term = "wezterm"
    table.insert(launch_menu, {
        label = "bash",
        args = { "bash" }
    })
    table.insert(launch_menu, {
        label = "zsh",
        args = { "zsh" }
    })
    table.insert(launch_menu, {
        label = "fish",
        args = { "fish" }
    })
    config.default_prog = { 'zsh' }
    config.set_environment_variables = set_environment_variables_linux
else
    config.term ="xterm-256color"
    -- config.set_environment_variables = set_environment_variables_windows
    -- config.win32_system_backdrop = 'Acrylic'
    -- config.win32_system_backdrop = 'Mica'
    -- config.win32_system_backdrop = 'Tabbed'
    -- config.background = {
    --     {
    --         source = {
    --             File = "D:\\bg\\abg\\(pid-56669634)博麗霊夢_p0.png",
    --         },
    --         opacity = 0.33,
    --     }
    -- }
end

-- Multiplexing
config.exec_domains = {
  wezterm.exec_domain('scoped', function(cmd)
    -- The "cmd" parameter is a SpawnCommand object.
    -- You can log it to see what's inside:
    wezterm.log_info(cmd)

    -- Synthesize a human understandable scope name that is
    -- (reasonably) unique. WEZTERM_PANE is the pane id that
    -- will be used for the newly spawned pane.
    -- WEZTERM_UNIX_SOCKET is associated with the wezterm
    -- process id.
    local env = cmd.set_environment_variables
    local ident = 'wezterm-pane-'
      .. env.WEZTERM_PANE
      .. '-on-'
      .. basename(env.WEZTERM_UNIX_SOCKET)
    -- Generate a new argument array that will launch a
    -- program via systemd-run
    local wrapped = {
      '/usr/bin/systemd-run',
      '--user',
      '--scope',
      '--description=Shell started by wezterm',
      '--same-dir',
      '--collect',
      '--unit=' .. ident,
    }

    -- Append the requested command
    -- Note that cmd.args may be nil; that indicates that the
    -- default program should be used. Here we're using the
    -- shell defined by the SHELL environment variable.
    for _, arg in ipairs(cmd.args or { os.getenv 'SHELL' }) do
      table.insert(wrapped, arg)
    end

    -- replace the requested argument array with our new one
    cmd.args = wrapped

    -- and return the SpawnCommand that we want to execute
    return cmd
  end),
}


config.ssh_domains = {}
config.leader = keymap_config.leader
config.key_tables = keymap_config.key_tables
config.keys = keymap_config.keys
config.mouse_bindings = keymap_config.mouse_bindings
config.launch_menu = launch_menu

return config
