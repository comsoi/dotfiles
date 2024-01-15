# Alias
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"
alias -- -="cd -"

alias wo='win32yank.exe -o'
alias wi='win32yank.exe -i'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias p="pwd"
alias v="lvim"
alias r="yazi"
alias ipy='ipython'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
	alias l='ls -CF --color=auto'
	alias ll='ls -alF --color=auto'
	alias la='ls -A --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias l="exa -al --icons --group-directories-first"
alias ll="exa -a --icons --group-directories-first"
# alias ssh="kitty +kitten ssh"
alias tree="tree -aC"

alias gs="git status"
alias ga="git add -A"
alias gc="git commit -v"
alias gc!="git commit -v --amend --no-edit"
alias gl="git pull"
alias gp="git push"
alias gp!="git push --force"
alias gcl="git clone --depth 1 --single-branch"
alias gf="git fetch --all"
alias gb="git branch"
alias gr="git rebase"
alias gt='cd "$(git rev-parse --show-toplevel)"'


function noproxy {
	unset all_proxy
	unset ALL_PROXY
	unset http_proxy
	unset HTTP_PROXY
	unset https_proxy
	unset HTTPS_PROXY
	echo "Proxy settings removed."
}

function setproxy {
	# host_ip=$(grep "nameserver" /etc/resolv.conf | cut -f 2 -d ' ')
	host_ip="127.0.0.1"
	host_port="2080"
	export all_proxy="http://$host_ip:$host_port"
	export ALL_PROXY="http://$host_ip:$host_port"
	export http_proxy="http://$host_ip:$host_port"
	export HTTP_PROXY="http://$host_ip:$host_port"
	export https_proxy="http://$host_ip:$host_port"
	export HTTPS_PROXY="http://$host_ip:$host_port"
	echo "Proxy set to: $host_ip:$host_port"
}

function ya() {
	tmp="$(mktemp -t "yazi-cwd")"
	~/Desktop/yazi/target/debug/yazi --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function gpr() {
	local username=$(git config user.name)
	if [ -z "$username" ]; then
		echo "Please set your git username"
		return 1
	fi

	local origin=$(git config remote.origin.url)
	if [ -z "$origin" ]; then
		echo "No remote origin found"
		return 1
	fi

	local remote_username=$(basename $(dirname $origin))
	if [ "$remote_username" != "$username" ]; then
		local new_origin=${origin/\/$remote_username\//\/$username\/}
		new_origin=${new_origin/https:\/\/github.com\//git@github.com:/}

		git config remote.origin.url $new_origin
		git remote remove upstream > /dev/null 2>&1
		git remote add upstream $origin
	fi

	git checkout -b "pr-$(openssl rand -hex 4)"
}

# Store commands in history only if successful
# CREDITS:
# https://gist.github.com/danydev/4ca4f5c523b19b17e9053dfa9feb246d
# https://scarff.id.au/blog/2019/zsh-history-conditional-on-command-success/

function __fd18et_prevent_write() {
  __fd18et_LASTHIST=$1
  return 2
}
function __fd18et_save_last_successed() {
  if [[ ($? == 0 || $? == 130) && -n $__fd18et_LASTHIST && -n $HISTFILE ]] ; then
	print -sr -- ${=${__fd18et_LASTHIST%%'\n'}}
  fi
}
add-zsh-hook zshaddhistory __fd18et_prevent_write
add-zsh-hook precmd __fd18et_save_last_successed
add-zsh-hook zshexit __fd18et_save_last_successed
