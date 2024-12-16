# If not running interactively, don't do anything
[[ $- != *i* ]] && return

ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
typeset -U path PATH

for file in "$ZDOTDIR"/core/*.zsh(N); do
	source "$file"
done
