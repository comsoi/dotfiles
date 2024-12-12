#
# Functions
#
autoload -Uz add-zsh-hook

if [[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash" ]]; then
	source "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash"
fi


function append_env {
	[[ -z "$1" || -z "$2" || ! -d "$2" || ":${(P)1}:" == *":$2:"* ]] && return
	if [[ "$3" == "prefix" ]]; then
		typeset -g $1="$2${(P)1:+:${(P)1}}"
	else
		typeset -g $1="${(P)1:+${(P)1}:}$2"
	fi
}


# cursor style
if [[ -z $P9K_TTY || -z $ZVM_INIT_DONE || ! $ZLE_RPROMPT_INDENT ]]; then
	zle-keymap-select () {
		case $KEYMAP in
			(vicmd | block) echo -ne '\e[1 q' ;;
			(main | viins | '' | beam) echo -ne '\e[5 q' ;;
		esac
	}
	zle-line-init() { zle-keymap-select 'beam' }
	zle -N zle-keymap-select
	zle -N zle-line-init
fi


# Store commands in history only if successful
# CREDITS:
# https://gist.github.com/danydev/4ca4f5c523b19b17e9053dfa9feb246d
# https://scarff.id.au/blog/2019/zsh-history-conditional-on-command-success/
__fd18et_prevent_write() {
	__fd18et_LASTHIST=$1
	return 2
}
__fd18et_save_last_successed() {
	if [[ ($? == 0 || $? == 130) && -n $__fd18et_LASTHIST && -n $HISTFILE ]]; then
		print -sr -- ${=${__fd18et_LASTHIST%%'\n'}}
	fi
}

add-zsh-hook zshaddhistory __fd18et_prevent_write
add-zsh-hook precmd __fd18et_save_last_successed
add-zsh-hook zshexit __fd18et_save_last_successed

# plugins
source "${ZDOTDIR}/plugins/completion.plugin.zsh"
if [[ ! $USE_OMZ ]]; then
	source "${ZDOTDIR}/plugins/sudo.plugin.zsh"
	source "${ZDOTDIR}/plugins/zsh-tab-title.plugin.zsh"
fi