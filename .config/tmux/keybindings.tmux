# Key Bindings
# RTF # https://github.com/tmux/tmux/issues/4162
# since 3.5a
# C-S-Tab -> c-BTAB
# Enter   -> C-m
# Tab     -> C-i
# C-Space -> C-@
# C-[     -> Escape
# Set the prefix (leader) key to Ctrl+S
unbind C-b
unbind '"'
unbind %
set -g prefix 'C-s'
bind 'C-s' send-prefix
setw -g mode-keys vi
set -g mouse on


if-shell -b '[ "$(echo "$TMUX_VERSION < 3.5" | bc)" = 1 ]' " \
    bind -n C-S-Tab   select-window -p; \
    bind -n C-M-[     select-window -p"

# https://github.com/tmux/tmux/issues/2705
# tmux will trans csi-u to xterm modifykey
# set -s user-keys[0] '\033[9;5u'
# set -s user-keys[1] '\033[9;6u'
# bind -n User0 select-window -n
# bind -n User1 select-window -p

bind -n M-t      new-window -c "#{pane_current_path}"
bind -n C-S-T    new-window -c "#{pane_current_path}"
bind -n S-down   new-window -c "#{pane_current_path}"
bind    c        new-window -c "#{pane_current_path}"

bind -n C-S-W    kill-window

# Split panes using \ and - (defalut is % and ")
# Open new tmux splits in the same directory
bind    \\       split-window -h -c "#{pane_current_path}"
bind    -        split-window -v -c "#{pane_current_path}"
bind    Enter    split-window -c "#{pane_current_path}"  \; select-layout -n \; select-layout -p
bind -n M-n      split-window -c "#{pane_current_path}"  \; select-layout -n \; select-layout -p

# Navigate between windows (tabs)
bind -n M-1      select-window -t 1
bind -n M-2      select-window -t 2
bind -n M-3      select-window -t 3
bind -n M-4      select-window -t 4
bind -n M-5      select-window -t 5
bind -n M-6      select-window -t 6
bind -n M-7      select-window -t 7
bind -n M-8      select-window -t 8
bind -n M-9      select-window -t 9
bind -n C-Tab    select-window -n
bind -n C-BTab   select-window -p

bind -n C-M-]    select-window -n
bind -n M-Escape select-window -p

bind -n S-left prev
bind -n S-right next

# move windows (tabs)
bind -n M-\{     swap-window -t -1\; select-window -t -1
bind -n M-\}     swap-window -t +1\; select-window -t +1
bind    P        swap-window -t -1\; select-window -t -1
bind    N        swap-window -t +1\; select-window -t +1

# Switch panes
bind -n M-h      select-pane -L
bind -n M-l      select-pane -R
bind -n M-k      select-pane -U
bind -n M-j      select-pane -D

bind -n M-]      select-pane -t :.+
# https://github.com/sxyazi/yazi/issues/1621#issuecomment-2342793146
# bind -n M-[    select-pane -t :.-

bind -r h        select-pane -L
bind -r j        select-pane -D
bind -r k        select-pane -U
bind -r l        select-pane -R

# Resize panes
bind -n M-Left   resize-pane -L
bind -n M-Right  resize-pane -R
bind -n M-Up     resize-pane -U
bind -n M-Down   resize-pane -D
bind -r H        resize-pane -L 5
bind -r J        resize-pane -D 5
bind -r K        resize-pane -U 5
bind -r L        resize-pane -R 5

bind    s        display-panes
bind    S        choose-session

# Close current window (tab) and pane ()
bind    q        kill-window
bind -n M-q      kill-window
bind -n M-x      kill-pane

# Toggle fullscreen
bind -n F11      resize-pane -Z

bind    r        source-file ~/.config/tmux/tmux.conf

