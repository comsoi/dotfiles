# If not running interactively, don't do anything
[[ $- != *i* ]] && return

typeset -U path PATH

for file ("$ZDOTDIR"/core/*.zsh(N)) {
	source "$file"
}

unset file
