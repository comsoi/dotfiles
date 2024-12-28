setopt AUTO_CD INTERACTIVE_COMMENTS HIST_FCNTL_LOCK HIST_IGNORE_ALL_DUPS SHARE_HISTORY NOFLOWCONTROL
unsetopt AUTO_REMOVE_SLASH HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY FLOWCONTROL

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

fpath=(${ZDOTDIR}/functions $fpath)

HAS_FZF=$+commands[fzf]
HAS_ZOXIDE=$+commands[zoxide]
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

if [[ $USE_OMZ == true ]] {
	unset HISTFILE
	export ZSH="${ZDOTDIR}/oh-my-zsh"
	ZSH_THEME="powerlevel10k/powerlevel10k"
	HYPHEN_INSENSITIVE="true"
	zstyle ':omz:update' mode reminder; zstyle ':omz:update' frequency 26
	COMPLETION_WAITING_DOTS="true"; DISABLE_UNTRACKED_FILES_DIRTY="true"
	plugins=(command-not-found extract docker git github gitignore
	history-substring-search node npm nvm vscode sudo web-search
	zsh-autosuggestions zsh-syntax-highlighting #ohmyzsh-full-autoupdate # zsh-vi-mode
	)
	source $ZSH/oh-my-zsh.sh
	return
}

typeset -a PLUGIN_PATHS=(
	"${ZDOTDIR}/plugins/custom"
	"/usr/share/zsh/plugins"
	"/usr/share"
)
typeset -a PLUGINS=(
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-vi-mode
	zsh-no-ps2
)
for plugin (${PLUGINS[@]}) {
	for plugin_file (${^PLUGIN_PATHS}/$plugin/$plugin.plugin.zsh(N)) {
		source $plugin_file
		# echo "Loaded plugin: $plugin ($plugin_file)"
		break
	}
}

source ${ZDOTDIR}/p10k-classic.zsh
typeset -a THEME_P10K=(
	"/usr/share/zsh-theme-powerlevel10k"
	"${ZDOTDIR}/themes/powerlevel10k"
)
# command -v brew >/dev/null 2>&1 && THEME+=("$(brew --prefix)/share/powerlevel10k")
for theme_file (${^THEME_P10K}/powerlevel10k.zsh-theme(N)) {
	POWERLEVEL9K_TERM_SHELL_INTEGRATION=true; POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
	source "$theme_file"
	break
}

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
