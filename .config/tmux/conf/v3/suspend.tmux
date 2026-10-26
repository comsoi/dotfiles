# ==============================================================================
# v3 层：F12 挂起（3.0+）
# 临时挂起 tmux 的按键处理（嵌套会话时把按键全交给内层），再按一次恢复
# ==============================================================================

bind -T root F12 \
    set prefix None \; \
    set key-table off \; \
    if -F '#{pane_in_mode}' 'send-keys -X cancel' \; \
    refresh-client -S

bind -T off F12 \
    set -u prefix \; \
    set -u key-table \; \
    refresh-client -S

# ------------------------------------------------------------------------------
# 与 wezterm（Leader+g）/ zellij（Ctrl s g）对齐：前缀 + g 挂起，挂起状态下同键恢复
#   C-s g            挂起（等价 F12）
#   C-s（挂起时）g   恢复
#   C-s（挂起时）C-s 恢复（连按前缀两次，符合 tmux 习惯）
# F12 的老路径保留不变。
# ------------------------------------------------------------------------------

bind -T prefix g \
    set prefix None \; \
    set key-table off \; \
    if -F '#{pane_in_mode}' 'send-keys -X cancel' \; \
    refresh-client -S

bind -T off C-s switch-client -T off-prefix
bind -T off-prefix g \
    set -u prefix \; \
    set -u key-table \; \
    refresh-client -S
bind -T off-prefix C-s \
    set -u prefix \; \
    set -u key-table \; \
    refresh-client -S
