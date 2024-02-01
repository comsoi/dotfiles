# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH
export PATH="/d/Scoop/apps/tdm-gcc/current/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(history)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	adb
	conda-zsh-completion
	command-not-found
	extract
	deno
	docker
	git
	github
	gitignore
	history-substring-search
	node
	npm
	nvm
	volta
	vscode
	sudo
	web-search
	z
	zsh-autosuggestions
	zsh-syntax-highlighting
	ohmyzsh-full-autoupdate
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=zh_CN.UTF-8
#export LC_ALL=zh_CN.UTF-8
#export LANGUAGE=zh_CN.UTF-8
export PYTHONIOENCODING=UTF-8
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias la='ls -A'
alias l='ls -aCF'
alias ll='ls -alF'
alias ipy='ipython'
if [ "$(command -v eza)" ]; then
	alias l="eza -a --icons --group-directories-first -I='NTUSER.*|ntuser.*'"
	alias ll="eza -al --icons --group-directories-first"
fi
alias lvim='pwsh --NoProfile -c "c:\users\lenod\.local\bin\lvim.ps1"'

function tmux() {
	# execute tmux with script
	local TMUX="command tmux ${@}"
	local SHELL=/usr/bin/bash script -qO /dev/null -c "eval $TMUX"
}

function ya() {
	tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function lvim() {
	local XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
	local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
	local XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}

	local LUNARVIM_RUNTIME_DIR=${LUNARVIM_RUNTIME_DIR:-$XDG_DATA_HOME/lunarvim}
	local LUNARVIM_CONFIG_DIR=${LUNARVIM_CONFIG_DIR:-$XDG_CONFIG_HOME/lvim}
	local LUNARVIM_CACHE_DIR=${LUNARVIM_CACHE_DIR:-$XDG_CACHE_HOME/lvim}
	local LUNARVIM_BASE_DIR=${LUNARVIM_BASE_DIR:-$LUNARVIM_RUNTIME_DIR/lvim}

	nvim -u "$LUNARVIM_BASE_DIR/init.lua" "$@"
}

function noproxy {
	unset ALL_PROXY
	unset HTTP_PROXY
	unset HTTPS_PROXY
	unset NO_PROXY
	echo "Proxy settings removed."
}

function setproxy() {
	# IP=$(grep "nameserver" /etc/resolv.conf | cut -f 2 -d ' ')
	local IP="127.0.0.1"
	local PORT="2080"
	local PROT="socks5"

	for arg in "$@"; do
		case "$arg" in
			"-socks" | "-socks5")     # set socks proxy (local DNS)
				PROT="socks5"
				;;
			"-socks5h")               # set socks proxy (remote DNS)
				PROT="socks5h"
				;;
			"-http" | "-https")                  # set HTTP proxy
				PROT="http"
				;;
			*)
				if [[ "$arg" != -* ]]; then
					PORT="$arg"
				fi
				;;
		esac
	done

	local PROXY="$PROT://$IP:$PORT"

	export HTTP_PROXY="$PROXY"
	export HTTPS_PROXY="$PROXY"
	export ALL_PROXY="$PROXY"
	export NO_PROXY="localhost,127.0.0.1"
	echo "Proxy set to: $PROXY"
}

setproxy > /dev/null

eval "$(zoxide init zsh)"

[[ "$TERM_PROGRAM" == "vscode" ]] && . "/d/Scoop/apps/vscode/current/resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if [ -f '/d/programs/conda/Scripts/conda.exe' ]; then
	eval "$('/d/programs/conda/Scripts/conda.exe' 'shell.zsh' 'hook' | sed -e 's/"$CONDA_EXE" $_CE_M $_CE_CONDA "$@"/"$CONDA_EXE" $_CE_M $_CE_CONDA "$@" | tr -d \x27\\r\x27/g')"
fi
# <<< conda initialize <<<
