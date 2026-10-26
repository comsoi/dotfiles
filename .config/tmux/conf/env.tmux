# ==============================================================================
# 环境变量（由 tmux.conf 加载，语法兼容到 1.8）
# pane 不继承外层终端的特征变量（避免 pane 内程序误判所在终端）；
# 同时挂进 update-environment，attach 时从新客户端的环境刷新
# ==============================================================================

# wezterm
set-environment -gu WEZTERM_CONFIG_DIR
set-environment -gu WEZTERM_CONFIG_FILE
set-environment -gu WEZTERM_EXECUTABLE
set-environment -gu WEZTERM_EXECUTABLE_DIR
set-environment -gu WEZTERM_PANE
set-environment -gu WEZTERM_UNIX_SOCKET

# alacritty
set-environment -gu ALACRITTY_LOG
set-environment -gu ALACRITTY_SOCKET
set-environment -gu ALACRITTY_WINDOW_ID

# kitty
set-environment -gu KITTY_INSTALLATION_DIR
set-environment -gu KITTY_LISTEN_ON
set-environment -gu KITTY_PID
set-environment -gu KITTY_PUBLIC_KEY
set-environment -gu KITTY_WINDOW_ID

# 其他终端 / 编辑器
set-environment -gu GHOSTTY_RESOURCES_DIR
set-environment -gu ITERM_SESSION_ID
set-environment -gu KONSOLE_VERSION
set-environment -gu TABBY_CONFIG_DIRECTORY
set-environment -gu TERMINFO
set-environment -gu VSCODE_INJECTION
set-environment -gu WT_Session

# dsh-tui 的 tmux 真彩开关。
# dsh-tui 只凭 $TMUX 存在就把 chalk 从 3 级砍到 2 级（见其 lib/types/ink/colorize.js
# 的 clampChalkLevelForTmux），不检查外层终端是否有 RGB 能力；本机 tmux 3.7c +
# terminal-features 里的 *:RGB 已支持真彩透传，不设这个变量会把整套雾蓝降成
# 256 色近似（accent #7DA1DE -> ansi256(110)，明显发灰发淡）。
set-environment -g DSH_TUI_TMUX_TRUECOLOR 1

# 桌面会话
set-environment -gu DISPLAY
set-environment -gu WAYLAND_DISPLAY
set-environment -gu XDG_CONFIG_DIRS
set-environment -gu XDG_CURRENT_DESKTOP
set-environment -gu XDG_MENU_PREFIX
set-environment -gu XDG_SEAT
set-environment -gu XDG_SESSION_CLASS
set-environment -gu XDG_SESSION_DESKTOP
set-environment -gu XDG_SESSION_ID
set-environment -gu XDG_SESSION_TYPE
set-environment -gu XDG_VTNR

# 1.8/2.0 的 -a 追加不会补空格，多次追加会把变量名粘在一起；
# 单行追加并以空格开头，新旧版本行为一致
set -ga update-environment " WEZTERM_CONFIG_DIR WEZTERM_CONFIG_FILE WEZTERM_EXECUTABLE WEZTERM_EXECUTABLE_DIR WEZTERM_PANE WEZTERM_UNIX_SOCKET ALACRITTY_LOG ALACRITTY_SOCKET ALACRITTY_WINDOW_ID KITTY_INSTALLATION_DIR KITTY_LISTEN_ON KITTY_PID KITTY_PUBLIC_KEY KITTY_WINDOW_ID GHOSTTY_RESOURCES_DIR ITERM_SESSION_ID KONSOLE_VERSION TABBY_CONFIG_DIRECTORY TERMINFO VSCODE_INJECTION WT_Session DISPLAY WAYLAND_DISPLAY XDG_CONFIG_DIRS XDG_CURRENT_DESKTOP XDG_MENU_PREFIX XDG_SEAT XDG_SESSION_CLASS XDG_SESSION_DESKTOP XDG_SESSION_ID XDG_SESSION_TYPE XDG_VTNR"
