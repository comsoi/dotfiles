## 20-keybinding.zsh

# matching everything up to current cursor position
# man zshzle. Search for "History Control".
# man zshcontrib. Search for "up-line-or-beginning-search".
autoload  -Uz  up-line-or-beginning-search
autoload  -Uz  down-line-or-beginning-search
autoload  -Uz  edit-command-line
zle       -N   up-line-or-beginning-search
zle       -N   down-line-or-beginning-search
zle       -N   edit-command-line

function bind2maps () {
	local i sequence widget
	local -a maps

	while [[ "$1" != "--" ]]; do
		maps+=( "$1" )
		shift
	done
	shift

	sequence="${key[$1]}"
	widget="$2"

	[[ -z "$sequence" && "$1" == '^'* ]] && sequence="$1"
	# [[ -z "$sequence" ]] && { printf "bind2maps: unknown key: %s\n" "$1"; return 1; }

	for i in "${maps[@]}"; do
			bindkey -M "$i" "$sequence" "$widget"
	done
}

# remove esc seq for avoid alt key enter vicmd mode
bindkey -rM viins '^['
bindkey -M  viins '^X^[' vi-cmd-mode

# https://www.reddit.com/r/zsh/comments/eblqvq/comment/fb7337q/
# If NumLock is off, translate keys to make them appear the same as with NumLock on.
bindkey -s '^[OM' '^M'  # enter
bindkey -s '^[Ok' '+'
bindkey -s '^[Om' '-'
bindkey -s '^[Oj' '*'
bindkey -s '^[Oo' '/'
bindkey -s '^[OX' '='

# If someone switches our terminal to application mode (smkx), translate keys to make
# them appear the same as in raw mode (rmkx).
bindkey -s '^[OH' '^[[H'  # home
bindkey -s '^[OF' '^[[F'  # end
bindkey -s '^[OA' '^[[A'  # up
bindkey -s '^[OB' '^[[B'  # down
bindkey -s '^[OD' '^[[D'  # left
bindkey -s '^[OC' '^[[C'  # right

# Linux TTY sends different key codes. Translate them to regular.
bindkey -s '^[[1~' '^[[H'  # home
bindkey -s '^[[4~' '^[[F'  # end

# typeset -g -A key
# key=(
#     BackSpace  "${terminfo[kbs]}"
#     Home       "${terminfo[khome]}"
#     End        "${terminfo[kend]}"
#     Insert     "${terminfo[kich1]}"
#     Delete     "${terminfo[kdch1]}"
#     Up         "${terminfo[kcuu1]}"
#     Down       "${terminfo[kcud1]}"
#     Left       "${terminfo[kcub1]}"
#     Right      "${terminfo[kcuf1]}"
#     PageUp     "${terminfo[kpp]}"
#     PageDown   "${terminfo[knp]}"
# )

# if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
# 	autoload -Uz add-zle-hook-widget
# 	function zle_application_mode_start { echoti smkx }
# 	function zle_application_mode_stop { echoti rmkx }
# 	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
# 	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
# 	bind2key
#   return
# fi

source $ZDOTDIR/.zkbd/$TERM

bind2maps       viins vicmd -- Home           beginning-of-line
bind2maps       viins vicmd -- End            end-of-line
bind2maps       viins       -- Insert         overwrite-mode
bind2maps       viins vicmd -- Delete         delete-char
bind2maps emacs viins vicmd -- Up             up-line-or-beginning-search
bind2maps emacs viins vicmd -- Down           down-line-or-beginning-search
bind2maps       viins vicmd -- Left           backward-char
bind2maps       viins vicmd -- Right          forward-char
bind2maps emacs viins vicmd -- PageUp         up-line-or-history
bind2maps emacs viins vicmd -- PageDown       down-line-or-history

bind2maps emacs viins vicmd -- Ctrl-Left      backward-word
bind2maps emacs viins vicmd -- Ctrl-Right     forward-word
bind2maps emacs viins vicmd -- Ctrl-Delete    kill-word
bind2maps emacs viins vicmd -- Ctrl-Backspace backward-delete-word
# vim hjkl key bindings with alt
bind2maps emacs viins       -- '^[j'          down-line-or-beginning-search  # alt+j
bind2maps emacs viins       -- '^[k'          up-line-or-beginning-search    # alt+k
bind2maps emacs viins       -- '^[h'          backward-char                  # alt+h
bind2maps emacs viins       -- '^[l'          forward-char                   # alt+l
bind2maps emacs viins       -- '^[H'          backward-word                  # alt+H
bind2maps emacs viins       -- '^[L'          forward-word                   # alt+L

# emacs key bindings in viins mode
# use `bindkey -lL main` to check in which keymap the key is bound

# navigation
bindkey '^A'      beginning-of-line                    # ctrl + a
bindkey '^E'      end-of-line                          # ctrl + e
bindkey '^F'      forward-char                         # ctrl + f
bindkey '^[f'     forward-word                         # alt  + f
bindkey '^B'      backward-char                        # ctrl + b
bindkey '^[b'     backward-word                        # alt  + b
bindkey '^P'      up-line-or-beginning-search          # ctrl + p
bindkey '^N'      down-line-or-beginning-search        # ctrl + n
# search
bindkey '^R'      history-incremental-search-backward  # ctrl + r
bindkey '^S'      history-incremental-search-forward   # ctrl + s
bindkey '^Q'      push-line-or-edit                    # ctrl + q
# delete
bindkey '^U'      kill-whole-line                      # ctrl + u (bash ^A^K)
bindkey '^K'      kill-line                            # ctrl + k
bindkey '^W'      backward-kill-word                   # ctrl + w
bindkey '^[w'     backward-kill-line                   # alt  + w (bash ^U)
bindkey '^D'      delete-char                          # ctrl + d
bindkey '^[d'     kill-word                            # alt  + d

bindkey '^[^M'    self-insert-unmeta                   # alt + ctrl + m
bindkey '^[^J'    self-insert-unmeta                   # alt + ctrl + j

bindkey '^x^e'    edit-command-line
# bindkey '^V'      vi-quoted-insert                    # ctrl+v
# Ctrl + y - Paste
# Ctrl + _ - Undo
bindkey '^[.'     insert-last-word                     # alt+. (bash !$)

# bash behave
# Alt +. or !$ - Previous commands last arguement !* - All arguments of previous command
# Alt + l/u - Lowercase/Uppercase word
# Alt + c - Capitalize Word
# Alt + Del - Delete previous word
# Alt + d - Delete next word
# Alt + t - Swap current word with previous word

# bindkey '^[u'     undo                                 # alt+u      undo
# bindkey '^[r'     redo                                 # alt+r      redo
