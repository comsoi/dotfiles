ZDOTDIR=$HOME/.config/zsh

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
HISTSIZE=10000
SAVEHIST=10000
KEYTIMEOUT=1  # makes the switch between modes quicker
HISTORY_SUBSTRING_SEARCH_PREFIXED=1  # enables prefixed search for zsh-history-substring-search

# Set language environment
if [[ $(tty) == /dev/pts/* ]]; then
	export LANG="zh_CN.UTF-8"
else
	export LANG="en_US.UTF-8"
fi
#export LC_ALL=zh_CN.UTF-8
#export LANGUAGE=zh_CN.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'
if [[ -n $SSH_CONNECTION ]]; then
	export VISUAL='vim'
else
	export VISUAL='lvim'
fi

# Enable less mouse scrolling
export LESS="-R"

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH

# OS
unameOut=$(uname -a)
case "${unameOut}" in
	*Microsoft*)     OS="WSL1";; #wls must be first since it will have Linux in the name too
	*microsoft*)     OS="WSL2";;
	Linux*)     OS="Linux";;
	Darwin*)    OS="Mac";;
	CYGWIN*)    OS="Cygwin";;
	MINGW*)     OS="Windows";;
	*Msys)     OS="Windows";;
	*)          OS="UNKNOWN:${unameOut}"
esac

# if [[ ${OS} == "Mac" ]] && sysctl -n machdep.cpu.brand_string | grep -q 'Apple M1'; then
#     #Check if its an M1. This check should work even if the current processes is running under x86 emulation.
#     OS="MacM1"
# fi

# Autorun
if [[ ${OS} == "WSL1" ]]; then
	is_sshd_running=`ps aux | grep sshd | grep -v grep`
	if [ -z "$is_sshd_running" ]; then
		sudo service ssh start > /dev/null
	fi
fi
