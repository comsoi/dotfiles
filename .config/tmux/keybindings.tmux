# Key Bindings

# Set the prefix (leader) key to Ctrl+S
unbind C-b
unbind '"'
unbind %

set -g prefix 'C-s'
bind 'C-s' send-prefix

setw -g  mode-keys         vi

set  -g  status-keys       emacs

bind    c        new-window -c "#{pane_current_path}"
bind    \\       split-window -h -c "#{pane_current_path}"
bind    -        split-window -v -c "#{pane_current_path}"
bind    Enter    split-window -c "#{pane_current_path}"  \; select-layout -n \; select-layout -p

# RTF # https://github.com/tmux/tmux/issues/4162
# since 3.5a
# C-S-Tab -> c-BTAB
# Enter   -> C-m
# Tab     -> C-i
# C-Space -> C-@
# C-[     -> Escape
if-shell -b '[ "$(echo "$(echo "$TERM_PROGRAM_VERSION" | sed "s/[^0-9.]//g") < 3.5" | bc)" = 1 ]' " \
	bind -n C-Tab    select-window -n; \
	bind -n C-S-Tab  select-window -p; \
	bind -n C-M-]    select-window -n; \
	bind -n C-M-[    select-window -p" " \
	bind -n C-Tab    select-window -n; \
	bind -n C-BTab   select-window -p; \
	bind -n C-M-]    select-window -n; \
	bind -n M-Escape select-window -p"

# CTRL SHIFT bindings
bind -n C-S-T    new-window   -c "#{pane_current_path}"
bind -n C-S-W    kill-window

# ALT bindings
bind -n M-t      new-window   -c "#{pane_current_path}"
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

# https://github.com/tmux/tmux/issues/2705
# tmux will trans csi-u to xterm modifykey
# set -s user-keys[0] '\033[9;5u'
# set -s user-keys[1] '\033[9;6u'
# bind -n User0 select-window -n
# bind -n User1 select-window -p

bind -n S-left prev
bind -n S-right next

# move windows (tabs)
bind -n M-\{     swap-window -t -1\; select-window -t -1
bind -n M-\}     swap-window -t +1\; select-window -t +1
bind    P        swap-window -t -1\; select-window -t -1
bind    N        swap-window -t +1\; select-window -t +1

# Switch panes
bind -n M-]      select-pane -t :.+
# https://github.com/sxyazi/yazi/issues/1621#issuecomment-2342793146
# bind -n M-[    select-pane -t :.-

bind -r h        select-pane -L
bind -r j        select-pane -D
bind -r k        select-pane -U
bind -r l        select-pane -R

# Resize panes
bind -r H        resize-pane -L 5
bind -r J        resize-pane -D 5
bind -r K        resize-pane -U 5
bind -r L        resize-pane -R 5
bind -r S-down   resize-pane -D 5
bind -r S-left   resize-pane -L 5
bind -r S-up     resize-pane -U 5
bind -r S-right  resize-pane -R 5

bind    s        display-panes

bind    e        choose-session
bind    E        switch-client -l

# Close current window (tab) and pane ()
bind    q        kill-window

# Toggle fullscreen
bind -n F11      resize-pane -Z

bind    R        source-file ~/.config/tmux/tmux.conf

bind -T root F12  \
  set prefix None \;\
  set key-table off \;\
  if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
  refresh-client -S \;\

bind -T off F12 \
  set -u prefix \;\
  set -u key-table \;\
  refresh-client -S

# '@pane-is-vim' is a pane-local option that is set by the plugin on load,
# and unset when Neovim exits or suspends; note that this means you'll probably
# not want to lazy-load smart-splits.nvim, as the variable won't be set until
# the plugin is loaded

# Smart pane switching with awareness of Neovim splits.
bind -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'select-pane -D'
bind -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'select-pane -L'
bind -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'select-pane -U'
bind -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'select-pane -R'

# Smart pane resizing with awareness of Neovim splits.
bind -n M-Left  if -F "#{@pane-is-vim}" 'send-keys M-Left ' 'resize-pane -L 5'
bind -n M-Right if -F "#{@pane-is-vim}" 'send-keys M-Right' 'resize-pane -R 5'
bind -n M-Up    if -F "#{@pane-is-vim}" 'send-keys M-Up   ' 'resize-pane -U 5'
bind -n M-Down  if -F "#{@pane-is-vim}" 'send-keys M-Down ' 'resize-pane -D 5'

if-shell -b '[ "$(echo "$(echo "$TERM_PROGRAM_VERSION" | sed "s/[^0-9.]//g") >= 3.0" | bc)" = 1 ]' \
	"bind -n 'C-\\' if -F \"#{@pane-is-vim}\" 'send-keys C-\\\\' 'select-pane -L'" \
	"bind -n 'C-\\' if -F \"#{@pane-is-vim}\" 'send-keys C-\\'   'select-pane -L'"

bind-key -n C-Up   send-keys -X previous-prompt
bind-key -n C-Down send-keys -X next-prompt

bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l

bind-key -n C-Up   copy-mode \; send-keys -X previous-prompt \; send-keys -X cancel
bind-key -n C-Down copy-mode \; send-keys -X next-prompt \; send-keys -X cancel

bind-key -T copy-mode-vi J send-keys -X next-prompt
bind-key -T copy-mode-vi K send-keys -X previous-prompt

bind-key -T copy-mode-vi C-n send-keys -X next-prompt
bind-key -T copy-mode-vi C-p send-keys -X previous-prompt

# # Setup 'v' to begin selection as in Vim
unbind -T copy-mode-vi 'v'
unbind -T copy-mode-vi 'y'
unbind -T copy-mode-vi MouseDragEnd1Pane
unbind -T copy-mode-vi Enter   #this is the default binding for copy (but not to system clipboard)

# since tmux 3.2
set -s copy-command 'wl-copy'

bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel

bind-key -T copy-mode-vi 'p' run "wl-paste --no-newline | tmux load-buffer - ; tmux paste-buffer"
