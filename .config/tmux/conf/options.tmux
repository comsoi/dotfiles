# ==============================================================================
# 终端与通用选项（由 tmux.conf 加载，全部为 1.8 时代就存在的选项）
# 3.0+ 的新选项在 conf/v3/options.tmux
# ==============================================================================

# 固定默认命令为 zsh（原先那段向 wezterm 上报 TMUX user var 的 DCS/OSC 1337 前缀已移除：
# wezterm 侧改为按前台进程名判断复用器，见 ~/.config/wezterm/utils/pane_proc_cache.lua）
set -g default-command    'exec /usr/bin/env zsh'
set -s default-terminal   "tmux-256color"

set  -g  history-limit     50000
set  -s  escape-time       5
setw -g  aggressive-resize on

# 忽略一切 bell
set  -g  visual-activity   off
set  -g  visual-bell       off
set  -g  visual-silence    off
set  -g  bell-action       none
setw -g  monitor-activity  off

# 编号从 1 开始，关窗自动重排
set  -g  base-index        1
setw -g  pane-base-index   1
set  -g  renumber-windows  on
setw -g  automatic-rename  on
set  -g  set-titles        on
