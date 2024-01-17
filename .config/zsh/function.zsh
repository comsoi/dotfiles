# Functions

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
