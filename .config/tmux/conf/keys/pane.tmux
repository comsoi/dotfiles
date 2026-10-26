# ==============================================================================
# 键位：窗格（pane）（由 tmux.conf 加载，语法兼容到 1.8）
#
# 需要检测 nvim 的键位，这里用 ps 探测做兜底（任何版本可用）；
# conf/v3/smart-splits.tmux 会用 smart-splits 的 @pane-is-vim
# 覆盖为零开销版本
# ==============================================================================

# Alt+hjkl 智能切换（兜底版）：pane 里是 nvim 就把按键送进去，否则切 tmux pane
# ps 的 [^TXZ] 过滤已停止/僵尸进程
bind -n M-h if-shell 'ps -o state= -o comm= -t "#{pane_tty}" | grep -iqE "^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$"' 'send-keys M-h' 'select-pane -L'
bind -n M-j if-shell 'ps -o state= -o comm= -t "#{pane_tty}" | grep -iqE "^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$"' 'send-keys M-j' 'select-pane -D'
bind -n M-k if-shell 'ps -o state= -o comm= -t "#{pane_tty}" | grep -iqE "^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$"' 'send-keys M-k' 'select-pane -U'
bind -n M-l if-shell 'ps -o state= -o comm= -t "#{pane_tty}" | grep -iqE "^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$"' 'send-keys M-l' 'select-pane -R'

# 循环切换 pane；M-[ 留给 yazi（https://github.com/sxyazi/yazi/issues/1621）
bind -n M-] select-pane -t :.+
# bind -n M-[ select-pane -t :.-

# 前缀 + hjkl 切换，可按住重复
bind -r h select-pane -L
bind -r j select-pane -D
bind -r k select-pane -U
bind -r l select-pane -R

# 前缀 + HJKL / Shift+方向键 调整大小
bind -r H       resize-pane -L 5
bind -r J       resize-pane -D 5
bind -r K       resize-pane -U 5
bind -r L       resize-pane -R 5
bind -r S-down  resize-pane -D 5
bind -r S-left  resize-pane -L 5
bind -r S-up    resize-pane -U 5
bind -r S-right resize-pane -R 5

bind    s   display-panes
bind -n F11 resize-pane -Z

# 与 wezterm Leader 层对齐（只补“同键同义”的；m 按要求不加）
# S：显示 pane 编号，按数字即与当前 pane 交换 —— 等价 wezterm Leader+S 的“标签选择”。
#    display-panes 的 template 会把 %% 换成选中的 pane ID 再执行；-d 0 = 显示到按键为止。
#    注意：裸 swap-pane 不指定 -t 时源/目标都是当前 pane（空操作），必须给 -t 或 -U/-D。
bind S display-panes -d 0 "swap-pane -t '%%'"
# 想“与相邻 pane 直接交换”（= 默认 { 的语义）就用这行代替上一行：
# bind S swap-pane -U
bind O select-pane -t :.-   # Leader+O：上一个 pane（tmux 默认只有 o = 下一个）
bind . break-pane           # Leader+.：把 pane 移出为新窗口（覆盖默认的“移动窗口到指定编号”）
