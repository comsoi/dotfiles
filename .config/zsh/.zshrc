# If not running interactively, don't do anything
[[ $- != *i* ]] && return
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt MENU_COMPLETE
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
unsetopt AUTO_REMOVE_SLASH
unsetopt HIST_EXPIRE_DUPS_FIRST
unsetopt EXTENDED_HISTORY

if [[ -r "${ZDOTDIR}/key_binding.zsh" ]]; then
	source ${ZDOTDIR}/key_binding.zsh
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH
if [[ "$(uname -sm)" = "Darwin arm64" ]] then export PATH=/opt/homebrew/bin:$PATH; fi

# To customize prompt, run `p10k configure` or edit .p10k.zsh.
[[ ! -f ${ZDOTDIR}/.p10k.zsh ]] || source ${ZDOTDIR}/.p10k.zsh

# Oh My Zsh
# Path to your oh-my-zsh installation.
if [[ -r $HOME/.oh-my-zsh ]]; then

	export ZSH="$HOME/.oh-my-zsh"

	# Set name of the theme to load --- if set to "random", it will
	# load a random theme each time oh-my-zsh is loaded, in which case,
	# to know which specific one was loaded, run: echo $RANDOM_THEME
	# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
	ZSH_THEME="powerlevel10k/powerlevel10k"
	POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(history)
	POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
	# Set list of themes to pick from when loading at random
	# Setting this variable when ZSH_THEME=random will cause zsh to load
	# a theme from this variable instead of looking in $ZSH/themes/
	# If set to an empty array, this variable will have no effect.
	# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

	# Uncomment the following line to use hyphen-insensitive completion.
	# Case-sensitive completion must be off. _ and - will be interchangeable.
	# HYPHEN_INSENSITIVE="true"

	# Uncomment one of the following lines to change the auto-update behavior
	# zstyle ':omz:update' mode disabled  # disable automatic updates
	zstyle ':omz:update' mode auto      # update automatically without asking
	# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

	# Uncomment the following line to change how often to auto-update (in days).
	zstyle ':omz:update' frequency 26

	# Uncomment the following line to disable colors in ls.
	# DISABLE_LS_COLORS="true"

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
		yarn
		volta
		vscode
		sudo
		web-search
		# z
		zsh-autosuggestions
		zsh-syntax-highlighting
		ohmyzsh-full-autoupdate
	)

	eval "$(zoxide init zsh)"
	eval $(thefuck --alias)

	source $ZSH/oh-my-zsh.sh

	# key bindings
	bindkey '^H'      backward-delete-word                 # ctrl+bs    delete one word backward
	bindkey '^X'      forward-word                         # ctrl+x     go forward one word
else
	eval "$(zoxide init zsh)"
	eval $(thefuck --alias)
	# case-insensitive auto-complete matches
	zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
	autoload -Uz compinit && compinit
	# Plugins
    if [[ -r /usr/share/zsh/plugins ]]; then
		source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
		source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	else
		source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
		source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	fi
	# NOTICE .powerlevel10k/ !!!
	if [[ -r "${ZDOTDIR}/.powerlevel10k" ]]; then
		POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
		source ${ZDOTDIR}/.powerlevel10k/powerlevel10k.zsh-theme
		elif [[ -r /usr/share/zsh-theme-powerl220evel10k ]]; then
		POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
		source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
		elif [[ -r "${HOME}/.powerlevel10k" ]]; then
		POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
		source ${HOME}/.powerlevel10k/powerlevel10k.zsh-theme
	fi
fi

# User configuration

# Initialize tools
source $ZDOTDIR/function.zsh
source $ZDOTDIR/.aliases

setproxy > /dev/null
