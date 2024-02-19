# If not running interactively, don't do anything
[[ $- != *i* ]] && return
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
unsetopt AUTO_REMOVE_SLASH
unsetopt HIST_EXPIRE_DUPS_FIRST
unsetopt EXTENDED_HISTORY


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# load OS specific config
case `uname` in
	Darwin)
		# source $ZDOTDIR/zshrc-mac.zsh
	;;
	Linux)
		# source $ZDOTDIR/zshrc-linux.zsh
	;;
	FreeBSD)
		# commands for FreeBSD go here
	;;
esac

# To customize prompt, run `p10k configure` or edit .p10k.zsh.
[[ ! -f ${ZDOTDIR}/.p10k.zsh ]] || source ${ZDOTDIR}/.p10k.zsh

# Oh My Zsh
# Path to your oh-my-zsh installation.
if [[ -r $HOME/.oh-my-zsh ]]; then
	export ZSH="$HOME/.oh-my-zsh"
	ZSH_THEME="powerlevel10k/powerlevel10k"
	HYPHEN_INSENSITIVE="true"           # _ and - will be interchangeable.
	zstyle ':omz:update' mode auto      # update automatically without asking
	zstyle ':omz:update' frequency 26   # check for updates every 26 days
	ENABLE_CORRECTION="true"
	# Uncomment the following line to display red dots whilst waiting for completion.
	# You can also set it to another string to have that shown instead of the default red dots.
	# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
	# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
	# COMPLETION_WAITING_DOTS="true"
	# under VCS as dirty. This makes repository status check for large repositories
	# much, much faster.
	# DISABLE_UNTRACKED_FILES_DIRTY="true"
	# Standard plugins can be found in $ZSH/plugins/ | Custom plugins may in $ZSH_CUSTOM/plugins/
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
else
	eval "$(zoxide init zsh)"
	eval $(thefuck --alias)
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
		elif [[ -r /usr/share/zsh-theme-powerlevel10k ]]; then
		POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
		source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
		elif [[ -r "${HOME}/.powerlevel10k" ]]; then
		POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
		source ${HOME}/.powerlevel10k/powerlevel10k.zsh-theme
	fi
fi


# User configuration

if [[ -r "${ZDOTDIR}/key_binding.zsh" ]]; then
	source ${ZDOTDIR}/key_binding.zsh
fi

if [[ -r "${ZDOTDIR}/completion.zsh" ]]; then
    source ${ZDOTDIR}/completion.zsh
fi

# Initialize tools
source $ZDOTDIR/function.zsh
source $ZDOTDIR/.aliases

# Set default environment variables
setproxy -http > /dev/null
