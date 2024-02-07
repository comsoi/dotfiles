#
# ~/.bash_profile
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ -f "$HOME/.bashrc" ]; then
. "$HOME/.bashrc"
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
	else
	color_prompt=
	fi
fi

# Shows Git branch name in prompt.
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

shorten_path() {
	# 将 IFS（内部字段分隔符）设置为斜杠，并将路径读入数组
	IFS='/' read -ra ADDR <<< "$1"
	shortpath=""
	for i in "${ADDR[@]:1}"; do # 从索引1开始以跳过空的首元素
		shortpath+="/${i:0:1}"  # 连接每个部分的首字母
	done
	echo $shortpath
}

if [ "$color_prompt" = yes ]; then
	PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$(shorten_path "\w")\[\033[00m\]$(parse_git_branch)\$ '
	# PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
else
	PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt


# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;\u@\h: \w\a\]$PS1"
		;;
	*)
		;;
esac

if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'


#==============================================================================

function tmux() {
  # execute tmux with script
  TMUX="command tmux ${@}"
  SHELL=/usr/bin/bash script -qO /dev/null -c "eval $TMUX"
}

function ya() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
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



# 显示 用户 @ 主机
# export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
# 隐藏 @ 主机，显示用户
# export PS1="\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\]"
# 显示当前文件夹
# export PS1="\[\e[32;1m\]\W $\[\e[0m\]\[\033[32m\]\$(parse_git_branch)\[\033[00m\] "
# 显示全路径
#export PS1="\[\e[32;1m\]\w $\[\e[0m\]\[\033[32m\]\$(parse_git_branch)\[\033[00m\] "


alias python3='python'
alias ipy='ipython'
if [ "$(command -v eza)" ]; then
	alias l="eza -a --icons --group-directories-first -I='NTUSER.*|ntuser.*'"
	alias ll="eza -al --icons --group-directories-first"
fi

export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN.UTF-8
#export LC_ALL=zh_CN.UTF-8


# export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
# chcp.com 65001
export PROMPT_COMMAND='history -a'


# if [ -t 1 ]; then
#   exec zsh
# fi
eval "$(zoxide init bash)"

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if [ -f '/d/programs/conda/Scripts/conda.exe' ]; then
	eval "$('/d/programs/conda/Scripts/conda.exe' 'shell.bash' 'hook')"
fi
# <<< conda initialize <<<
