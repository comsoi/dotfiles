# If not running interactively, don't do anything
[[ $- != *i* ]] && return

ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
typeset -U path PATH

for file ("$ZDOTDIR"/core/*.zsh(N)) {
	source "$file"
}

unset file
