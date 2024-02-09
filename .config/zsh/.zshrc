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
unsetopt flowcontrol

# Refence:
# https://www.reddit.com/r/zsh/comments/eblqvq/comment/fb7337q/
# If NumLock is off, translate keys to make them appear the same as with NumLock on.
bindkey -s '^[OM' '^M'  # enter
bindkey -s '^[Ok' '+'
bindkey -s '^[Om' '-'
bindkey -s '^[Oj' '*'
bindkey -s '^[Oo' '/'
bindkey -s '^[OX' '='

# If someone switches our terminal to application mode (smkx), translate keys to make
# them appear the same as in raw mode (rmkx).
bindkey -s '^[OH' '^[[H'  # home
bindkey -s '^[OF' '^[[F'  # end
bindkey -s '^[OA' '^[[A'  # up
bindkey -s '^[OB' '^[[B'  # down
bindkey -s '^[OD' '^[[D'  # left
bindkey -s '^[OC' '^[[C'  # right

# TTY sends different key codes. Translate them to regular.
bindkey -s '^[[1~' '^[[H'  # home
bindkey -s '^[[4~' '^[[F'  # end

# `up-line-or-beginning-search` 函数绑定到向上箭头键，允许您搜索先前的命令。
# `down-line-or-beginning-search` 函数绑定到向下箭头键，允许您搜索下一个命令。
# 这些函数是自动加载的，并与 `up-line-or-beginning-search` 和 `down-line-or-beginning-search` ZLE 小部件关联。
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^H'      backward-delete-word                 # ctrl+bs    delete one word backward
bindkey '^X'      forward-word                         # ctrl+m     go forward one word


# emacs key bindings
# ctrl+key
bindkey '^A'      beginning-of-line                    # ctrl+a     go to the beginning of line
bindkey '^E'      end-of-line                          # ctrl+e     go to the end of line
# <- and -> arrows
bindkey '^F'      forward-char                         # ctrl+f     move cursor one char forward
bindkey '^B'      backward-char                        # ctrl+b     move cursor one char backward
# up and down arrows
bindkey '^P'      up-line-or-beginning-search          # ctrl+p     prev command in history
bindkey '^N'      down-line-or-beginning-search        # ctrl+n     next command in history
# search
bindkey '^R'      history-incremental-search-backward  # ctrl+r     search history backward
bindkey '^S'      history-incremental-search-forward   # ctrl+s     search history forward
bindkey '^Q'      push-line-or-edit                    # ctrl+q     push line
# delete
bindkey '^U'      backward-kill-line                   # ctrl+u     delete from cursor to beginning of line  (default ^U)
bindkey '^K'      kill-line                            # ctrl+k     delete from cursor to end of line
bindkey '^W'      backward-kill-word                   # ctrl+w     delete previous word
# [[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}"  delete-char  # another way to bind delete
bindkey '^D'      delete-char                          # ctrl+d     delete one char forward
bindkey '^[[3~'   delete-char                          # delete     delete one char forward
# Make Ctrl-Left and Ctrl-Right jump words.
bindkey '^[[1;5C' forward-word                         # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                        # ctrl+left  go backward one word
bindkey '^[[H'    beginning-of-line                    # home       go to the beginning of line
bindkey '^[[F'    end-of-line                          # end        go to the end of line

# default key bindings
# bindkey '^?'      backward-delete-char                 # bs         delete one char backward                (default ^?)
# bindkey '^L'      clear-screen                         # ctrl+l     clear screen                             (default ^L)
# bindkey '^[[D'    backward-char                 # left       move cursor one char backward
# bindkey '^[[C'    forward-char                  # right      move cursor one char forward
# bindkey '^[[A'    up-line-or-beginning-search   # up         prev command in history
# bindkey '^[[B'    down-line-or-beginning-search # down       next command in history

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
		yarn
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
elif [[ -r /usr/share/zsh/plugins ]]; then
	# Plugins
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
	else
	echo 'powerlevel10k not found'
fi


# User configuration

# case-insensitive auto-complete matches
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit && compinit

# Initialize tools
source $ZDOTDIR/function.zsh
source $ZDOTDIR/.aliases

setproxy > /dev/null

eval "$(zoxide init zsh)"
eval $(thefuck --alias)
