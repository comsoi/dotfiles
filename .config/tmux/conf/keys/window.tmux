# ==============================================================================
# 键位：窗口（tab）（由 tmux.conf 加载，语法兼容到 1.8）
# ==============================================================================

bind -n C-S-T new-window -c "#{pane_current_path}"
bind -n C-S-W kill-window

bind -n M-t   new-window   -c "#{pane_current_path}"
bind -n M-n   split-window -c "#{pane_current_path}" \; select-layout -n \; select-layout -p

bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9

bind -n S-left  prev
bind -n S-right next

# C-Tab 系切换
# tmux 3.5 改了按键名（https://github.com/tmux/tmux/issues/4162）：
#   C-S-Tab -> C-BTab    C-[ 与 Escape 冲突，prev 改用 M-Escape
# 版本判断用 #{version}（服务端自身版本；2.6 以下展开为空，走旧按键名分支，恰好正确）
if-shell '[ -n "#{version}" ] && [ "$(printf "3.5\n%s\n" "#{version}" | sed -E "s/[^0-9.].*$//" | sort -V | head -n1)" = "3.5" ]' " \
    bind -n C-Tab    select-window -n; \
    bind -n C-BTab   select-window -p; \
    bind -n C-M-]    select-window -n; \
    bind -n M-Escape select-window -p" " \
    bind -n C-Tab    select-window -n; \
    bind -n C-S-Tab  select-window -p; \
    bind -n C-M-]    select-window -n; \
    bind -n C-M-[    select-window -p"

# 移动窗口（swap-window 的相对序号 ±1 需要 2.x；1.8 上语义不同，无碍）
bind -n 'M-{' swap-window -t -1 \; select-window -t -1
bind -n 'M-}' swap-window -t +1 \; select-window -t +1
bind    P     swap-window -t -1 \; select-window -t -1
bind    N     swap-window -t +1 \; select-window -t +1

bind    q     kill-window
# f：跨 pane 模糊搜索（内容 + 最近历史）并跳转，替换内置 find-window（只看可见区、且不自动跳）
#    想用内置版本时仍可手动敲：:find-window -CNT 关键字
#    脚本不进 PATH；tmux 加载配置时就会展开 $HOME（文件里不含用户名）
bind    f     display-popup -E -w 90% -h 70% -T "find pane" "sh $HOME/.config/tmux/scripts/mux-find-pane.sh tmux"
