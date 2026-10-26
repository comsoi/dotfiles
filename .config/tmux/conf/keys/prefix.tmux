# ==============================================================================
# 键位：前缀 / 模式 / 拆分（由 tmux.conf 加载，语法兼容到 1.8）
#
# 写法约定：
#   - 特殊按键加引号："\\"、'M-{'（1.8/2.x 的配置解析器不认裸 \\ 和 M-\{）
# ==============================================================================

unbind C-b
unbind '"'
unbind %

set -g prefix 'C-s'
bind 'C-s' send-prefix

setw -g mode-keys   vi
set  -g status-keys emacs

# 新建/拆分均继承当前路径（-c 需要 1.9+；1.8 上这几条绑定失败，回退到默认行为）
bind    c     new-window    -c "#{pane_current_path}"
bind    "\\"  split-window  -h -c "#{pane_current_path}"
bind    -     split-window  -v -c "#{pane_current_path}"
bind    Enter split-window  -c "#{pane_current_path}" \; select-layout -n \; select-layout -p
