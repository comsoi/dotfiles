# ==============================================================================
# v3 层：smart-splits.nvim 集成（3.0+）
# 覆盖 conf/keys/pane.tmux 里的 ps 兜底版。
# @pane-is-vim 由插件在 Neovim 启动/退出时设置，故 smart-splits.nvim 不宜懒加载
# ==============================================================================

# Alt+hjkl：zoom 时先走"轮转 + 补回 zoom"（对齐 wezterm 的 cycle 策略——wezterm 的
# activate_pane_direction 一遇 zoom 就先取消 zoom，那边同样是"转完再贴回去"拼出来的）；
# 未 zoom 时：nvim 内交给 smart-splits，否则切 tmux pane；
# 左右方向到 pane 边界时切 window（对齐 wezterm 的 activate_pane_or_tab 行为，
# previous/next-window 自带环绕）。
# #{pane_at_left/right} 是 3.1+ 的 format，3.0a 展开为空 -> 退化为纯 pane 移动
# 轮转方向沿用 wezterm 的 directions 表：Left/Down = 上一个，Right/Up = 下一个
#
# 嵌套引号是必须的：外层 else 用单引号包住整条 if，它内部要用双引号，再往里那层只能转义。
# 这里刻意不用 {} 命令块——那套语法的引入版本没查实，而本文件只保证 tmux 3.0+。
bind -n M-h if -F "#{window_zoomed_flag}" 'select-pane -t :.- ; resize-pane -Z' 'if -F "#{@pane-is-vim}" "send-keys M-h" "if -F \"#{pane_at_left}\" \"previous-window\" \"select-pane -L\""'
bind -n M-j if -F "#{window_zoomed_flag}" 'select-pane -t :.+ ; resize-pane -Z' 'if -F "#{@pane-is-vim}" "send-keys M-j" "select-pane -D"'
bind -n M-k if -F "#{window_zoomed_flag}" 'select-pane -t :.- ; resize-pane -Z' 'if -F "#{@pane-is-vim}" "send-keys M-k" "select-pane -U"'
bind -n M-l if -F "#{window_zoomed_flag}" 'select-pane -t :.+ ; resize-pane -Z' 'if -F "#{@pane-is-vim}" "send-keys M-l" "if -F \"#{pane_at_right}\" \"next-window\" \"select-pane -R\""'

bind -n M-Left  if -F "#{@pane-is-vim}" 'send-keys M-Left ' 'resize-pane -L 5'
bind -n M-Right if -F "#{@pane-is-vim}" 'send-keys M-Right' 'resize-pane -R 5'
bind -n M-Up    if -F "#{@pane-is-vim}" 'send-keys M-Up   ' 'resize-pane -U 5'
bind -n M-Down  if -F "#{@pane-is-vim}" 'send-keys M-Down ' 'resize-pane -D 5'

# C-\：回到上一个 pane（对齐 vim-tmux-navigator 的"previous"语义）
bind -n 'C-\' if -F "#{@pane-is-vim}" 'send-keys C-\\' 'select-pane -l'
