setopt AUTO_CD INTERACTIVE_COMMENTS HIST_FCNTL_LOCK HIST_IGNORE_ALL_DUPS SHARE_HISTORY NOFLOWCONTROL
unsetopt AUTO_REMOVE_SLASH HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY FLOWCONTROL

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HAS_FZF=$+commands[fzf]
HAS_ZOXIDE=$+commands[zoxide]
HAS_THEFUCK=$+commands[thefuck]
HAS_WIN32YANK=$+commands[win32yank.exe]
HAS_NALA=$+commands[nala]
HAS_LSD=$+commands[lsd]
HAS_EZA=$+commands[eza]
HAS_TRASH_PUT=$+commands[trash-put]
HAS_BAT=$+commands[bat]
HAS_DIRCOLORS=$+commands[dircolors]

function zvm_config {
	ZVM_VI_INSERT_ESCAPE_BINDKEY='jj'; ZVM_INIT_MODE='sourcing'
}

if [[ $USE_OMZ == true ]]; then
	unset HISTFILE
	export ZSH="${ZDOTDIR}/oh-my-zsh"
	ZSH_THEME="powerlevel10k/powerlevel10k"
	HYPHEN_INSENSITIVE="true"
	zstyle ':omz:update' mode reminder; zstyle ':omz:update' frequency 26
	COMPLETION_WAITING_DOTS="true"; DISABLE_UNTRACKED_FILES_DIRTY="true"
	plugins=(command-not-found extract docker git github gitignore
	history-substring-search node npm nvm vscode sudo web-search
	zsh-autosuggestions zsh-syntax-highlighting ohmyzsh-full-autoupdate)
	source $ZSH/oh-my-zsh.sh
	return
fi

typeset -a PLUGIN_PATHS=("/usr/share/zsh/plugins" "${ZDOTDIR}/plugins/custom")
typeset -a PLUGINS=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-vi-mode")
typeset PLUGINS_LOADED=false
for PLUGIN_DIR in "${PLUGIN_PATHS[@]}"; do
	if [[ -r "$PLUGIN_DIR" ]]; then
		for plugin in "${PLUGINS[@]}"; do
			source "$PLUGIN_DIR/$plugin/$plugin.zsh"
		done
		PLUGINS_LOADED=true; break
	fi
done
if ! $PLUGINS_LOADED; then
	for plugin in "${PLUGINS[@]}"; do
		source "/usr/share/$plugin/$plugin.zsh"
	done
	PLUGINS_LOADED="manual"
fi

[[ -f ${ZDOTDIR}/.p10k.zsh ]] && source ${ZDOTDIR}/.p10k.zsh
typeset -a THEME=(
	"/usr/share/zsh-theme-powerlevel10k"
	"${ZDOTDIR}/themes/powerlevel10k"
	# "$(brew --prefix)/share/powerlevel10k"
)
# command -v brew >/dev/null 2>&1 && THEME+=("$(brew --prefix)/share/powerlevel10k")

for THEME_DIR in "${THEME[@]}"; do
	if [[ -r "$THEME_DIR" ]]; then
		POWERLEVEL9K_TERM_SHELL_INTEGRATION=true; POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
		source "$THEME_DIR/powerlevel10k.zsh-theme"
		break
	fi
done

# Initialize tools
# move to the last zshrc
if (( HAS_FZF )); then
    FZF_VERSION=$(fzf --version)
    FZF_MAJOR=${FZF_VERSION%%.*}
    FZF_MINOR=${FZF_VERSION#*.}
    FZF_MINOR=${FZF_MINOR%%.*}
    if (( FZF_MAJOR > 0 )) || (( FZF_MAJOR == 0 && FZF_MINOR > 48 )); then
        source <(fzf --zsh)
    fi
fi

if (( HAS_ZOXIDE )); then
    eval "$(zoxide init zsh --cmd j)"
fi

# eval $(thefuck --alias)
if (( HAS_THEFUCK )); then
    fuck () {
        TF_PYTHONIOENCODING=$PYTHONIOENCODING
        export TF_SHELL=zsh
        export TF_ALIAS=fuck
        TF_SHELL_ALIASES=$(alias)
        export TF_SHELL_ALIASES
        TF_HISTORY="$(fc -ln -10)"
        export TF_HISTORY
        export PYTHONIOENCODING=utf-8
        TF_CMD=$(thefuck THEFUCK_ARGUMENT_PLACEHOLDER "$@") && eval "$TF_CMD"
        unset TF_HISTORY
        export PYTHONIOENCODING=$TF_PYTHONIOENCODING
        [[ -n "$TF_CMD" ]] && print -s "$TF_CMD"
    }
fi
