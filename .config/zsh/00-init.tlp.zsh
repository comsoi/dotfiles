setopt AUTO_CD INTERACTIVE_COMMENTS HIST_FCNTL_LOCK HIST_IGNORE_ALL_DUPS SHARE_HISTORY
unsetopt AUTO_REMOVE_SLASH HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY
HISTFILE=$ZDOTDIR/.history; KEYTIMEOUT=20

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
		ZVM_VI_INSERT_ESCAPE_BINDKEY='jj'; ZVM_INIT_MODE='sourcing'
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
if command -v fzf >/dev/null && fzf --version | cut -d' ' -f1 | awk '{exit ($1 <= "0.48.0")}'; then
	source <(fzf --zsh)
fi

if [[ $(command -v zoxide) ]]; then
	eval "$(zoxide init zsh --cmd j)"
fi

# eval $(thefuck --alias)
if [[ $(command -v thefuck) ]]; then
	fuck () {
		TF_PYTHONIOENCODING=$PYTHONIOENCODING;
		export TF_SHELL=zsh;
		export TF_ALIAS=fuck;
		TF_SHELL_ALIASES=$(alias);
		export TF_SHELL_ALIASES;
		TF_HISTORY="$(fc -ln -10)";
		export TF_HISTORY;
		export PYTHONIOENCODING=utf-8;
		TF_CMD=$(
			thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
		) && eval $TF_CMD;
		unset TF_HISTORY;
		export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
		test -n "$TF_CMD" && print -s $TF_CMD
	}
fi

