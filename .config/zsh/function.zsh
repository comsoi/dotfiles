#
# Functions
#

if [ -f "${HOME}/.bash_functions" ]; then
	source "${HOME}/.bash_functions"
fi

# oh-my-zsh seems to enable this by default, not desired for
# workflow of controlling terminal title.
# DISABLE_AUTO_TITLE="true"

function set_terminal_title() {
	echo -en "\e]2;$@\a"
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

autoload -U add-zsh-hook

add-zsh-hook zshaddhistory __fd18et_prevent_write
add-zsh-hook precmd __fd18et_save_last_successed
add-zsh-hook zshexit __fd18et_save_last_successed
