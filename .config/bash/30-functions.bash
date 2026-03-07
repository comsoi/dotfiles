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
	# Use the quote function to properly handle special characters and quoting
	local quoted_command
	quoted_command=$(quote "$@")

	echo "Executing: hyprctl dispatch -- exec $quoted_command"
	hyprctl dispatch -- exec "$quoted_command"
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

	(($#)) || return

	for i; do
		c=''
		e=1

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

function __get_model {
	_unameOut=$(uname -a)
	case "${_unameOut}" in
	*Microsoft*) OS="WSL1" ;;
	*microsoft*) OS="WSL2" ;;
	Linux*) OS="Linux" ;;
	Darwin*) OS="Mac" ;;
	CYGWIN*) OS="Cygwin" ;;
	MINGW*) OS="Windows" ;;
	*Msys) OS="Windows" ;;
	*) OS="UNKNOWN:${_unameOut}" ;;
	esac

	if [ "${OS}" = "Mac" ] && sysctl -n machdep.cpu.brand_string | grep -q 'Apple M'; then
		OS="MacArm"
	fi
	case $OS in
	Linux)
		if [[ -d /system/app/ && -d /system/priv-app ]]; then
			model="$(getprop ro.product.brand) $(getprop ro.product.model)"

		elif [[ -f /sys/devices/virtual/dmi/id/product_name ||
			-f /sys/devices/virtual/dmi/id/product_version ]]; then
			model=$(</sys/devices/virtual/dmi/id/product_name)
			model+=" $(</sys/devices/virtual/dmi/id/product_version)"

		elif [[ -f /sys/firmware/devicetree/base/model ]]; then
			model=$(</sys/firmware/devicetree/base/model)

		elif [[ -f /tmp/sysinfo/model ]]; then
			model=$(</tmp/sysinfo/model)
		fi
		;;

	"Mac OS X" | "macOS" | "Mac")
		if [[ $(kextstat | grep -F -e "FakeSMC" -e "VirtualSMC") != "" ]]; then
			model="Hackintosh (SMBIOS: $(sysctl -n hw.model))"
		else
			model=$(sysctl -n hw.model)
		fi
		;;

	Windows)
		model=$(wmic computersystem get manufacturer,model)
		model=${model/Manufacturer/}
		model=${model/Model/}
		;;

	esac

	# Remove dummy OEM info.
	model=${model//To be filled by O.E.M./}
	model=${model//To Be Filled*/}
	model=${model//OEM*/}
	model=${model//Not Applicable/}
	model=${model//System Product Name/}
	model=${model//System Version/}
	model=${model//Undefined/}
	model=${model//Default string/}
	model=${model//Not Specified/}
	model=${model//Type1ProductConfigId/}
	model=${model//INVALID/}
	model=${model//All Series/}
	model=${model//�/}

	case $model in
	"Standard PC"*) model="KVM/QEMU (${model})" ;;
	OpenBSD*) model="vmm ($model)" ;;
	esac
}

function noproxy {
	unset all_proxy
	unset http_proxy
	unset https_proxy
	unset no_proxy
	echo "Proxy settings removed."
}

function setproxy {
	local IP="127.0.0.1"
	local PORT="7897"
	__get_model
	if [[ ${model} == *"VMware"* ]]; then
		local ip_address=$(ip a | grep 'scope global dynamic' | awk '{print $2}')
		IP=$(echo "$ip_address" | sed 's/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\.[0-9]\{1,3\}/\1.1/; s/\/[0-9]\{1,2\}//')
		PORT="7897"
	fi
	local PROT="http"

	local ip_set=0
	for arg in "$@"; do
		case "$arg" in
		"-socks" | "-socks5") # set socks proxy
			PROT="socks5"
			;;
		"-http" | "-https") # set HTTP proxy
			PROT="http"
			;;
		*)
			if [[ "$arg" != -* ]]; then
				if [[ "$arg" =~ ^[0-9]+$ ]]; then
					# If argument is numeric, treat as port
					PORT="$arg"
				elif [[ "$arg" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
					# If argument matches IP format, treat as IP
					IP="$arg"
				fi
			fi
			;;
		esac
	done

	local PROXY="$PROT://$IP:$PORT"

	export http_proxy="$PROXY"
	export https_proxy="$PROXY"
	export all_proxy="$PROXY"
	export no_proxy="172.31.*,172.30.*,172.29.*,172.28.*,172.27.*,172.26.*,172.25.*,172.24.*,172.23.*,172.22.*,172.21.*,172.20.*,172.19.*,172.18.*,172.17.*,172.16.*,10.*,192.168.*,127.*,localhost,<local>"
	echo "Proxy set to: $PROXY"
}

if [[ $EXTGLOB_WAS_ON -ne 0 && -n "$BASH_VERSION" ]]; then
	shopt -u extglob
fi
