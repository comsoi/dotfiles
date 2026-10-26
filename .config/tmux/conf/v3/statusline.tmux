# ==============================================================================
# v3 层：状态栏（catppuccin + cpu/battery 插件，3.0+）
# ==============================================================================

set -g @catppuccin_flavor 'mocha'
set -g @catppuccin_window_status_style "rounded"

run ~/.config/tmux/plugins/tmux-catppuccin/catppuccin.tmux

set -g   status-right-length 100
set -g   status-left-length  100
set -g   status-left  "#{?window_zoomed_flag,Z,}"
set -g   status-right "#{E:@catppuccin_status_application}"
set -agF status-right "#{E:@catppuccin_status_cpu}"
set -ag  status-right "#{E:@catppuccin_status_session}"
set -ag  status-right "#{E:@catppuccin_status_uptime}"
set -agF status-right "#{E:@catppuccin_status_battery}"

run ~/.config/tmux/plugins/tmux-battery/battery.tmux
run ~/.config/tmux/plugins/tmux-cpu/cpu.tmux
# run ~/.config/tmux/plugins/tmux-yank/yank.tmux
