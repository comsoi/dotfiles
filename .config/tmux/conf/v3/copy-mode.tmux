# ==============================================================================
# v3 层：复制模式（3.0+；copy-mode-vi 表与 send-keys -X 均为 2.4+ 语法）
# ==============================================================================

# OSC 133 prompt 跳转：root 表跳转后不留在复制模式，复制模式内 J/K/C-n/C-p 连续翻
bind -n C-Up   copy-mode \; send-keys -X previous-prompt \; send-keys -X cancel
bind -n C-Down copy-mode \; send-keys -X next-prompt     \; send-keys -X cancel

bind -T copy-mode-vi J   send-keys -X next-prompt
bind -T copy-mode-vi K   send-keys -X previous-prompt
bind -T copy-mode-vi C-n send-keys -X next-prompt
bind -T copy-mode-vi C-p send-keys -X previous-prompt

# 复制模式内 C-hjkl 直接跨 pane，C-\ 回上一个（C-\ 必须加引号，3.4 及以下裸写会解析错）
bind -T copy-mode-vi C-j   select-pane -D
bind -T copy-mode-vi C-h   select-pane -L
bind -T copy-mode-vi C-k   select-pane -U
bind -T copy-mode-vi C-l   select-pane -R
bind -T copy-mode-vi 'C-\' select-pane -l

# v 选择；y / 拖动 / 回车 复制到系统剪贴板（经 copy-command = wl-copy）
unbind -T copy-mode-vi v
unbind -T copy-mode-vi y
unbind -T copy-mode-vi MouseDragEnd1Pane
unbind -T copy-mode-vi Enter   # 默认只进 tmux buffer，不进系统剪贴板

bind -T copy-mode-vi v                 send-keys -X begin-selection
bind -T copy-mode-vi y                 send-keys -X copy-pipe-and-cancel
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
bind -T copy-mode-vi Enter             send-keys -X copy-pipe-and-cancel

bind -T copy-mode-vi p run "wl-paste --no-newline | tmux load-buffer - ; tmux paste-buffer"
