#! /bash

unsetopt flowcontrol
setopt noflowcontrol

# remove esc seq for avoid alt key enter vicmd mode
bindkey -rM viins '^['
bindkey -M  viins '^j'   vi-cmd-mode
bindkey -M  viins '^X^[' vi-cmd-mode

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

# Linux TTY sends different key codes. Translate them to regular.
bindkey -s '^[[1~' '^[[H'  # home
bindkey -s '^[[4~' '^[[F'  # end

typeset -g -A key
key=(
    BackSpace  "${terminfo[kbs]}"
    Home       "${terminfo[khome]}"
    End        "${terminfo[kend]}"
    Insert     "${terminfo[kich1]}"
    Delete     "${terminfo[kdch1]}"
    Up         "${terminfo[kcuu1]}"
    Down       "${terminfo[kcud1]}"
    Left       "${terminfo[kcub1]}"
    Right      "${terminfo[kcuf1]}"
    PageUp     "${terminfo[kpp]}"
    PageDown   "${terminfo[knp]}"
)

# https://coderwall.com/p/jpj_6q/zsh-better-history-searching-with-arrow-keys
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# emacs key bindings

# make sure bind in `bindkey -A viins main`
# use `bindkey -lL main` to check

# navigation
bindkey '^A'      beginning-of-line                    # ctrl+a     go to the beginning of line
bindkey '^E'      end-of-line                          # ctrl+e     go to the end of line
bindkey '^F'      forward-char                         # ctrl+f     go one char forward
bindkey '^B'      backward-char                        # ctrl+b     go one char backward
bindkey '^[f'     forward-word                         # alt+f      go forward one word
bindkey '^[b'     backward-word                        # alt+b      go backward one word
bindkey '^[[1;5C' forward-word                         # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                        # ctrl+left  go backward one word
bindkey '^[[H'    beginning-of-line                    # home       go to the beginning of line
bindkey '^[[F'    end-of-line                          # end        go to the end of line
# vim hjkl key bindings with alt in viins mode
bindkey '^[j'     down-line-or-beginning-search        # alt+j      next command in history
bindkey '^[k'     up-line-or-beginning-search          # alt+k      prev command in history
bindkey '^[h'     backward-char                        # alt+h      move cursor one char backward
bindkey '^[l'     forward-char                         # alt+l      move cursor one char forward
bindkey '^[H'     backward-word                        # alt+H      move cursor one word backward
bindkey '^[L'     forward-word                         # alt+L      move cursor one word forward
# up and down arrows
bindkey '^P'      up-line-or-beginning-search          # ctrl+p     prev command in history
bindkey '^N'      down-line-or-beginning-search        # ctrl+n     next command in history
bindkey "^[[5~"   up-line-or-history                   # PageUp
bindkey "^[[6~"   down-line-or-history                 # PageDown
bindkey '^[[A'    up-line-or-beginning-search          # arrowdown  prev command in history
bindkey '^[[B'    down-line-or-beginning-search        # arrowup    next command in history
# search
bindkey '^R'      history-incremental-search-backward  # ctrl+r     search history backward
bindkey '^S'      history-incremental-search-forward   # ctrl+s     search history forward
bindkey '^Q'      push-line-or-edit                    # ctrl+q     push line
# delete
bindkey '^U'      kill-whole-line                      # ctrl+u     delete the whole line             (zsh ^U)
bindkey '^K'      kill-line                            # ctrl+k     delete from cursor to end of line
bindkey '^W'      backward-kill-word                   # ctrl+w     delete previous word
# [[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}"  delete-char  # another way to bind delete
bindkey '^D'      delete-char                          # ctrl+d     delete one char forward
bindkey '^[[3~'   delete-char                          # delete     delete one char forward
bindkey '^[[3;5~' kill-word                            # ctrl+del   delete next word
bindkey '^[d'     kill-word                            # alt+d      delete next word
bindkey '^H'      backward-delete-word                 # ctrl+bs    delete one word backward
bindkey '^[w'     backward-kill-line                   # alt+w      delete from cursor to beginning of line

autoload -U edit-command-line
zle -N edit-command-line
# Emacs style
bindkey '^x^e' edit-command-line
# Ctrl + y - Paste
# Ctrl + _ - Undo

# default key bindings
# bindkey '^?'      backward-delete-char                 # bs         delete one char backward        (default ^?)
# bindkey '^L'      clear-screen                         # ctrl+l     clear screen                    (default ^L)

bindkey '^[^M'    self-insert-unmeta                   # alt+ctrl+m   insert next char literally
bindkey '^[^J'    self-insert-unmeta                   # alt+ctrl+j   insert next char literally
bindkey '^[.'     insert-last-word                     # alt+.        insert last word of previous command

# bash behave
# Alt +. or !$ - Previous commands last arguement !* - All arguments of previous command
# Alt + l/u - Lowercase/Uppercase word
# Alt + c - Capitalize Word
# Alt + Del - Delete previous word
# Alt + d - Delete next word
# Alt + t - Swap current word with previous word

# bindkey '^[u'     undo                                 # alt+u      undo
# bindkey '^[r'     redo                                 # alt+r      redo
