ZDOTDIR=$HOME/.config/zsh

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
HISTFILE=$ZDOTDIR/.history
HISTSIZE=10000
SAVEHIST=10000
KEYTIMEOUT=1  # makes the switch between modes quicker
HISTORY_SUBSTRING_SEARCH_PREFIXED=1  # enables prefixed search for zsh-history-substring-search

# Set language environment
if tty -s; then
	export LANG="en_US.UTF-8"
else
	export LANG="zh_CN.UTF-8"
fi
#export LC_ALL=zh_CN.UTF-8
#export LANGUAGE=zh_CN.UTF-8

# Preferred editor for local and remote sessions
EDITOR='vim'
if [[ -n $SSH_CONNECTION ]]; then
	export VISUAL='vim'
else
	export VISUAL='lvim'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
