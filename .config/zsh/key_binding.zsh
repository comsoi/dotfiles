unsetopt flowcontrol

# Refence:
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

# TTY sends different key codes. Translate them to regular.
bindkey -s '^[[1~' '^[[H'  # home
bindkey -s '^[[4~' '^[[F'  # end

# `up-line-or-beginning-search` 函数绑定到向上箭头键，允许您搜索先前的命令。
# `down-line-or-beginning-search` 函数绑定到向下箭头键，允许您搜索下一个命令。
# 这些函数是自动加载的，并与 `up-line-or-beginning-search` 和 `down-line-or-beginning-search` ZLE 小部件关联。
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search


# emacs key bindings
# ctrl+key
bindkey '^A'      beginning-of-line                    # ctrl+a     go to the beginning of line
bindkey '^E'      end-of-line                          # ctrl+e     go to the end of line
# <- and -> arrows
bindkey '^F'      forward-char                         # ctrl+f     move cursor one char forward
bindkey '^B'      backward-char                        # ctrl+b     move cursor one char backward
# up and down arrows
bindkey '^P'      up-line-or-beginning-search          # ctrl+p     prev command in history
bindkey '^N'      down-line-or-beginning-search        # ctrl+n     next command in history
# search
bindkey '^R'      history-incremental-search-backward  # ctrl+r     search history backward
bindkey '^S'      history-incremental-search-forward   # ctrl+s     search history forward
bindkey '^Q'      push-line-or-edit                    # ctrl+q     push line
# delete
bindkey '^U'      kill-whole-line                      # ctrl+u     delete the whole line                     (zsh ^U)
bindkey '^K'      kill-line                            # ctrl+k     delete from cursor to end of line
bindkey '^W'      backward-kill-word                   # ctrl+w     delete previous word
# [[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}"  delete-char  # another way to bind delete
bindkey '^D'      delete-char                          # ctrl+d     delete one char forward
bindkey '^[[3~'   delete-char                          # delete     delete one char forward
# Make Ctrl-Left and Ctrl-Right jump words.
bindkey '^[[1;5C' forward-word                         # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                        # ctrl+left  go backward one word
bindkey '^[[H'    beginning-of-line                    # home       go to the beginning of line
bindkey '^[[F'    end-of-line                          # end        go to the end of line
# Ctrl + y - Paste
# Ctrl + _ - Undo

# default key bindings
# bindkey '^?'      backward-delete-char                 # bs         delete one char backward                (default ^?)
# bindkey '^L'      clear-screen                         # ctrl+l     clear screen                            (default ^L)
# bindkey '^[[D'    backward-char                 # left       move cursor one char backward
# bindkey '^[[C'    forward-char                  # right      move cursor one char forward
# bindkey '^[[A'    up-line-or-beginning-search   # up         prev command in history
# bindkey '^[[B'    down-line-or-beginning-search # down       next command in history

# alt+key
bindkey '^[f'     forward-word                         # alt+f      go forward one word
bindkey '^[b'     backward-word                        # alt+b      go backward one word
bindkey '^[d'     kill-word                            # alt+d      delete next word
bindkey '^[^?'    backward-kill-word                   # alt+bs     delete previous word
bindkey '^[^H'    backward-kill-word                   # alt+bs     delete previous word
# bindkey '^U'      backward-kill-line                   # ctrl+u     delete from cursor to beginning of line  (bash default ^U)
bindkey '^[^W'    backward-kill-line                   # alt+w      delete from cursor to beginning of line (zsh ^[^U)
bindkey '^[.'     insert-last-word                     # alt+.      insert last word of previous command
# Alt +. or !$ - Previous commands last arguement !* - All arguments of previous command
# Alt + l/u - Lowercase/Uppercase word
# Alt + c - Capitalize Word
# Alt + Del - Delete previous word
# Alt + d - Delete next word
# Alt + t - Swap current word with previous word

# key bindings
bindkey '^H'      backward-delete-word                 # ctrl+bs    delete one word backward
bindkey '^X'      forward-word                         # ctrl+x     go forward one word
# vim hjkl key bindings with alt
bindkey '^[h'     backward-char                        # alt+h      move cursor one char backward
bindkey '^[j'     down-line-or-beginning-search        # alt+j      next command in history
bindkey '^[k'     up-line-or-beginning-search          # alt+k      prev command in history
bindkey '^[l'     forward-char                         # alt+l      move cursor one char forward
# ctrl+alt+key
bindkey '^[^H'     backward-word                       # ctrl+alt+h go backward one word
bindkey '^[^L'     forward-word                        # ctrl+alt+l go forward one word
bindkey '^[u'     undo                                 # alt+u      undo
bindkey '^[r'     redo                                 # alt+r      redo
