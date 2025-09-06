#
# ~/.bash_aliases
#

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias cd=cd_func

declare -A _commands_vars=(
	["fzf"]="HAS_FZF"
	["zoxide"]="HAS_ZOXIDE"
	["thefuck"]="HAS_THEFUCK"
	["nala"]="HAS_NALA"
	["lsd"]="HAS_LSD"
	["eza"]="HAS_EZA"
	["trash-put"]="HAS_TRASH_PUT"
	["bat"]="HAS_BAT"
	["dircolors"]="HAS_DIRCOLORS"
)

for cmd in "${!_commands_vars[@]}"; do
	if command -v "$cmd" >/dev/null; then
		declare "${_commands_vars[$cmd]}=1"
	fi
done

unset _commands_vars

[[ -f ~/.config/zsh/core/40-aliases.zsh ]] && source ~/.config/zsh/core/40-aliases.zsh
