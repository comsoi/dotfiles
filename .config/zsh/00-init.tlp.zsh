setopt AUTO_CD INTERACTIVE_COMMENTS HIST_FCNTL_LOCK HIST_IGNORE_ALL_DUPS SHARE_HISTORY NOFLOWCONTROL
unsetopt AUTO_REMOVE_SLASH HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY FLOWCONTROL
KEYTIMEOUT=20
DIRSTACKSIZE=20

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

# fzf
if (( HAS_FZF )); then
	_fzf_ver=$(fzf --version | cut -d' ' -f1)
	if (( ${_fzf_ver%%.*} > 0 || ${${_fzf_ver#*.}%%.*} > 48 )); then
		source <(fzf --zsh)
	fi
	unset _fzf_ver
fi
# fzf --zsh > ${ZDOTDIR}/cache/fzf.zsh
# source ${ZDOTDIR}/cache/fzf.zsh
FZF_DEFAULT_OPTS='--bind "tab:down,shift-tab:up,ctrl-j:down,ctrl-k:up,alt-j:preview-down,alt-k:preview-up"'

# zoxide
if (( HAS_ZOXIDE )); then
	eval "$(zoxide init zsh --cmd j)"
fi
# zoxide init zsh --cmd j > ${ZDOTDIR}/cache/zoxide.zsh
# source ${ZDOTDIR}/cache/zoxide.zsh

# thefuck -- define fuck() in functions
# eval $(thefuck --alias)

# already defined in /etc/profile.d/cuda.sh
# export CUDA_PATH=/opt/cuda
# export NVCC_CCBIN=/usr/bin/g++-13
# path=(
#   "$CUDA_PATH/bin"
#   "$CUDA_PATH/nsight_compute"
#   "$CUDA_PATH/nsight_systems/bin"
#   $path
# )
# export CUDA_HOME="$CUDA_PATH"
# export CUDACXX="$CUDA_PATH"/bin/nvcc
# export CUDAHOSTCXX=/usr/bin/g++-13
# export HOST_COMPILER=/usr/bin/g++-13
# export NVCC_PREPEND_FLAGS='-ccbin /usr/bin/g++-13'
