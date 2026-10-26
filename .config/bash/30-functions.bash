#
# ~/.bash_functions
#

if [[ -n "$BASH_VERSION" ]]; then
	EXTGLOB_WAS_ON=$(shopt -q extglob)
	shopt -s extglob
fi

function mkcd {
	mkdir -p -- "$1" && cd -- "$1"
}

function packages-by-date {
	env LC_ALL=C pacman -Qi |
		grep '^\(Name\|Install Date\)\s*:' |
		cut -d ':' -f 2- |
		paste - - |
		while read pkg_name install_date; do
			install_date=$(date --date="$install_date" -Iseconds)
			echo "$install_date   $pkg_name"
		done | sort | tail -n 100
}

function quote {
	declare -a params
	for param; do
		if [[ -z "${param}" || "${param}" =~ [^A-Za-z0-9_@%+=:,./-] ]]; then
			params+=("'${param//\'/\'\"\'\"\'}'")
		else
			params+=("${param}")
		fi
	done
	echo "${params[*]}"
}

function hyprun {
	if [ "$#" -eq 0 ]; then
		echo "Usage: hyprun <command>"
		return 1
	fi
	# Hyprland 0.55+ (Lua config): dispatch takes a Lua dispatcher expression
	local quoted_command="$*"
	quoted_command="${quoted_command//\\/\\\\}"
	quoted_command="${quoted_command//\'/\\\'}"

	echo "Executing: hyprctl dispatch hl.dsp.exec_cmd('$quoted_command')"
	hyprctl dispatch "hl.dsp.exec_cmd('$quoted_command')"
}

function tmux {
	if [[ -n $TMUX ]]; then
		if [[ $# -eq 0 ]]; then
			command tmux new-window
			return
		else
			command tmux "$@"
			return
		fi
	fi

	if [[ $# -eq 0 ]]; then
		local target_path="$(pwd -P)"
		local found_pane=false
		local _window _pane _path _cmd
		while read -r _window _pane _path _cmd; do
			if [[ "$_path" == "$target_path" ]] && [[ " bash zsh fish pwsh nu " == *" $_cmd "* ]]; then
				if command tmux select-pane -t "$_pane" && command tmux select-window -t "$_window"; then
					found_pane=true
					break
				fi
			fi
		done < <(command tmux list-panes -s -F '#{window_id} #{pane_id} #{pane_current_path} #{pane_current_command}' 2>/dev/null)

		if $found_pane; then
			command tmux attach-session
		else
			command tmux new-window >/dev/null 2>&1
			command tmux new-session -A
		fi
	else
		command tmux "$@"
	fi
}

function cd_func {
	local x2 the_new_dir adir index
	local -i cnt

	if [[ $1 == "--" ]]; then
		dirs -v
		return 0
	fi

	the_new_dir=$1
	[[ -z $1 ]] && the_new_dir=$HOME

	if [[ ${the_new_dir:0:1} == '-' ]]; then
		#
		# Extract dir N from dirs
		index=${the_new_dir:1}
		[[ -z $index ]] && index=1
		adir=$(dirs +$index)
		[[ -z $adir ]] && return 1
		the_new_dir=$adir
	fi

	#
	# '~' has to be substituted by ${HOME}
	[[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

	#
	# Now change to the new dir and add to the top of the stack
	pushd "${the_new_dir}" >/dev/null
	[[ $? -ne 0 ]] && return 1
	the_new_dir=$(pwd)

	#
	# Trim down everything beyond 11th entry
	popd -n +11 2>/dev/null 1>/dev/null

	#
	# Remove any other occurence of this dir, skipping the top of the stack
	for ((cnt = 1; cnt <= 10; cnt++)); do
		x2=$(dirs +${cnt} 2>/dev/null)
		[[ $? -ne 0 ]] && return 0
		[[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
		if [[ "${x2}" == "${the_new_dir}" ]]; then
			popd -n +$cnt 2>/dev/null 1>/dev/null
			cnt=cnt-1
		fi
	done

	return 0
}

function eza_gs {
	eza -al --group-directories-first --git --git-ignore --no-user --no-filesize --no-time --no-permissions --tree --color=always | awk '$1 !~ /--/ { print }'
}

function y {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function gpr {
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
		git remote remove upstream >/dev/null 2>&1
		git remote add upstream $origin
	fi

	git checkout -b "pr-$(openssl rand -hex 4)"
}

extract() {
	local c e i

	# zsh needs kshglob for the @(...) case patterns below; scoped to this
	# function so the rest of the shell keeps its matching rules.
	if [[ -n "$ZSH_VERSION" ]]; then
		setopt localoptions
		setopt kshglob
	fi

	(($#)) || return

	for i; do
		c=''
		e=0

		if [[ ! -r $i ]]; then
			echo "$0: file is unreadable: \`$i'" >&2
			continue
		fi

		case $i in
		*.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz|zst)))))
			c=(bsdtar xvf)
			;;
		*.7z) c=(7z x) ;;
		*.Z) c=(uncompress) ;;
		*.bz2) c=(bunzip2) ;;
		*.exe) c=(cabextract) ;;
		*.gz) c=(gunzip) ;;
		*.rar) c=(unrar x) ;;
		*.xz) c=(unxz) ;;
		*.zip) c=(unzip) ;;
		*.zst) c=(unzstd) ;;
		*)
			echo "$0: unrecognized file extension: \`$i'" >&2
			continue
			;;
		esac

		command "${c[@]}" "$i"
		((e = e || $?))
	done
	return "$e"
}


# open: macOS-like, detached from terminal.
#   open [files...]          default app via xdg-open
#   open -d|-n|-t|-p|-c ...  force dolphin / nautilus / thunar / pcmanfm-qt / cosmic-files
#   open -f <cmd> ...        force any file manager
#   open -- ...              stop flag parsing (literal filenames)
function open {
	local fm="" arg
	local -a paths=()
	while (($#)); do
		case "$1" in
			-d) fm=dolphin ;;
			-n) fm=nautilus ;;
			-t) fm=thunar ;;
			-p) fm=pcmanfm-qt ;;
			-c) fm=cosmic-files ;;
			-f) shift; fm="$1" ;;
			--) shift; paths+=("$@"); break ;;
			*)  paths+=("$1") ;;
		esac
		shift
	done
	((${#paths[@]})) || paths=(".")

	local -a fixed=()
	for arg in "${paths[@]}"; do
		[[ "$arg" == -* ]] && arg="$PWD/$arg"
		fixed+=("$arg")
	done
	paths=("${fixed[@]}")

	if [[ -z "$fm" ]]; then
		for arg in "${paths[@]}"; do
			(xdg-open "$arg" >/dev/null 2>&1 &)
		done
	elif command -v "$fm" >/dev/null; then
		("$fm" "${paths[@]}" >/dev/null 2>&1 &)
	else
		echo "open: '$fm' not found" >&2
		return 1
	fi
}

function noproxy {
	unset all_proxy http_proxy https_proxy no_proxy \
		ALL_PROXY HTTP_PROXY HTTPS_PROXY NO_PROXY
	echo "Proxy settings removed."
}

# setproxy is loaded on first use from setproxy.bash. Guarded so zsh (which
# sources this file) keeps its own autoloaded port in ~/.config/zsh/functions.
if [[ -n "$BASH_VERSION" ]]; then
	function setproxy {
		unset -f setproxy
		if ! source "$HOME/.config/bash/setproxy.bash"; then
			echo "setproxy: failed to load ~/.config/bash/setproxy.bash" >&2
			return 1
		fi
		setproxy "$@"
	}
fi

if [[ $EXTGLOB_WAS_ON -ne 0 && -n "$BASH_VERSION" ]]; then
	shopt -u extglob
fi
