## 30-functions.zsh
autoload -Uz add-zsh-hook

if [[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash" ]] {
	source "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash"
}

function append_env {
	[[ -z "$1" || -z "$2" || ! -d "$2" || ":${(P)1}:" == *":$2:"* ]] && return
	if [[ "$3" == "prefix" ]] {
		typeset -g $1="$2${(P)1:+:${(P)1}}"
	} else {
		typeset -g $1="${(P)1:+${(P)1}:}$2"
	}
}

cbprint() {
	if [[ $OS == "Linux" ]] {
		if [[ -n "$WAYLAND_DISPLAY" ]] {
		wl-copy
		} else {
			xclip -selection primary -i -f | xclip -selection secondary -i -f | xclip -selection clipboard -i
		}
	} elif [[ $OS == "Mac" ]] {
		pbcopy
	} elif [[ $OS == "WSL"* ]] {
		win32yank.exe -i --format text
	}
}

cbprint() {
	if [[ $OS == "Linux" ]] {
		if [[ -n "$WAYLAND_DISPLAY" ]] {
			for sel (clipboard primary) {
				if x=$(wl-paste --no-newline --$sel 2> /dev/null) {
					echo -n $x
					return
				}
			}
		} elif (( $+commands[xsel] )) {
			for sel (clipboard primary secondary) {
				if x=$(xsel --output --$sel 2> /dev/null) {
					echo -n $x
					return
				}
		}
		} elif (( $+commands[xclip] )) {
			for sel (clipboard primary secondary ){
				if x=$(xclip -o -selection $sel 2> /dev/null) {
					echo -n $x
					return
				}
			}
		}
	} elif [[ $OS == "Mac"* ]] {
		pbpaste
	} elif [[ $OS == "Windows_NT" ]] {
		clip.exe
	} elif [[ $OS == "WSL"* ]] {
		win32yank.exe -o --format text
	}
}

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
source ${ZDOTDIR}/plugins/completion.plugin.zsh
if [[ ! $USE_OMZ ]] {
	source ${ZDOTDIR}/plugins/sudo.plugin.zsh
	source ${ZDOTDIR}/plugins/zsh-tab-title.plugin.zsh
}
