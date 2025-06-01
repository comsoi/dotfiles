# ~/.profile

[ -z "$HOME" ] && exit

export EDITOR='nvim'
export LESS="-R"

export QT_IM_MODULES="wayland;fcitx;ibus"
export GSK_RENDERER=ngl

if [ -d "/usr/lib/jvm/jre-jetbrains" ]; then
	export IDEA_JDK=/usr/lib/jvm/jre-jetbrains
	export PHPSTORM_JDK=/usr/lib/jvm/jre-jetbrains
	export WEBIDE_JDK=/usr/lib/jvm/jre-jetbrains
	export PYCHARM_JDK=/usr/lib/jvm/jre-jetbrains
	export RUBYMINE_JDK=/usr/lib/jvm/jre-jetbrains
	export CL_JDK=/usr/lib/jvm/jre-jetbrains
	export DATAGRIP_JDK=/usr/lib/jvm/jre-jetbrains
	export GOLAND_JDK=/usr/lib/jvm/jre-jetbrains
	export STUDIO_JDK=/usr/lib/jvm/jre-jetbrains
	export RUSTROVER_JDK=/usr/lib/jvm/jre-jetbrains
fi

if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
	if [ "$(cat /sys/class/drm/card1/*HDMI*/status)" = "disconnected" ]; then
		export __EGL_VENDOR_LIBRARY_FILENAMES="/usr/share/glvnd/egl_vendor.d/50_mesa.json"
		export VK_DRIVER_FILES="/usr/share/vulkan/icd.d/intel_icd.x86_64.json"
	fi
	export QT_QPA_PLATFORMTHEME=qt5ct
fi

{
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
	unset _unameOut
	export OS
}

if [ -n "$BASH_VERSION" ] || [ -n "ZSH_VERSION" ]; then
	add_env() {
		local mode="insert"
		local sep=":"
		local env_name
		local current_val
		local value_to_add

		# Option parsing
		while [ $# -gt 0 ]; do
			case "$1" in
			-a | --append)
				mode="append"
				shift
				;;
			-i | --insert)
				mode="insert"
				shift
				;;
			-s=* | --sep=*)
				sep="${1#*=}"
				if [ -z "$sep" ]; then
					echo "add_env: Error: Separator cannot be empty." >&2
					return 1 # Return from function with error status
				fi
				shift
				;;
			-s | --sep) # Handle -s VAL and --sep VAL
				if [ -n "$2" ]; then
					sep="$2"
					if [ -z "$sep" ]; then
						echo "add_env: Error: Separator for '$1' cannot be empty." >&2
						return 1
					fi
					shift 2
				else
					echo "add_env: Error: '$1' option requires an argument." >&2
					return 1
				fi
				;;
			-*)
				echo "add_env: Unknown option: $1" >&2
				return 1
				;;
			*)
				break # End of options
				;;
			esac
		done

		# Ensure at least one argument (environment variable name)
		if [ $# -lt 1 ]; then
			echo "add_env: Usage: add_env [options] VAR_NAME value1 [value2 ...]" >&2
			echo "add_env: No environment variable name specified." >&2
			return 1
		fi

		env_name="$1"
		shift # Remaining arguments are values to add

		# Get current value of the environment variable using indirect expansion
		current_val="${!env_name}"

		# Process all values to be added
		for value_to_add in "$@"; do
			# Skip empty values if desired
			if [ -z "$value_to_add" ]; then
				continue
			fi

			# Check if value already exists
			local temp_current_val_for_check="$sep$current_val$sep"
			local pattern_to_check="$sep$value_to_add$sep"

			case "$temp_current_val_for_check" in
			*"$pattern_to_check"*) continue ;; # Value already exists, skip
			esac

			# Add value
			if [ -z "$current_val" ]; then
				current_val="$value_to_add"
			elif [ "$mode" = "append" ]; then
				current_val="$current_val$sep$value_to_add"
			else # mode == "insert"
				current_val="$value_to_add$sep$current_val"
			fi
		done

		# Set the environment variable using printf -v for safety, then export
		if printf -v "$env_name" %s "$current_val"; then
			export "$env_name"
		else
			echo "add_env: Error: Failed to set environment variable '$env_name'." >&2
			return 1
		fi
		return 0 # Explicitly return success
	}
else
	add_env() {
		_add_env_mode="insert"
		_add_env_sep=":"
		_add_env_name=""
		_add_env_current=""
		_add_env_value=""
		_add_env_temp=""
		# 解析选项
		while [ $# -gt 0 ]; do
			case "$1" in
			-a | --append)
				_add_env_mode="append"
				shift
				;;
			-i | --insert)
				_add_env_mode="insert"
				shift
				;;
			-s=* | --sep=*)
				_add_env_sep="${1#*=}"
				if [ -z "$_add_env_sep" ]; then
					echo "add_env: Error: Separator cannot be empty." >&2
					return 1
				fi
				shift
				;;
			-s | --sep)
				if [ -n "$2" ]; then
					_add_env_sep="$2"
					if [ -z "$_add_env_sep" ]; then
						echo "add_env: Error: Separator cannot be empty." >&2
						return 1
					fi
					shift 2
				else
					echo "add_env: Error: '$1' requires an argument." >&2
					return 1
				fi
				;;
			-*)
				echo "add_env: Unknown option: $1" >&2
				return 1
				;;
			*)
				break
				;;
			esac
		done
		# 检查参数
		if [ $# -lt 1 ]; then
			echo "add_env: Usage: add_env [options] VAR_NAME value1 [value2 ...]" >&2
			return 1
		fi
		_add_env_name="$1"
		shift
		# 验证环境变量名
		case "$_add_env_name" in
		*[!A-Za-z0-9_]*)
			echo "add_env: Error: Invalid variable name: $_add_env_name" >&2
			return 1
			;;
		[0-9]*)
			echo "add_env: Error: Variable name cannot start with a number: $_add_env_name" >&2
			return 1
			;;
		esac
		# 获取当前值 - 使用 printenv 避免 eval
		_add_env_current=$(printenv "$_add_env_name" 2>/dev/null) || _add_env_current=""
		# 处理每个值
		for _add_env_value in "$@"; do
			[ -z "$_add_env_value" ] && continue
			# 对 PATH 类变量进行验证
			if [ "$_add_env_name" = "PATH" ] || [ "$_add_env_name" = "LD_LIBRARY_PATH" ] ||
				[ "$_add_env_name" = "MANPATH" ] || [ "$_add_env_name" = "PYTHONPATH" ]; then
				case "$_add_env_value" in
				*[\;\|\&\<\>\`\$\(\)\{\}\[\]\*\?]*)
					echo "add_env: Warning: Skipping value with unsafe characters: $_add_env_value" >&2
					continue
					;;
				esac
			fi
			# 检查值是否已存在
			_add_env_temp="$_add_env_sep$_add_env_current$_add_env_sep"
			case "$_add_env_temp" in
			*"$_add_env_sep$_add_env_value$_add_env_sep"*) continue ;;
			esac
			# 添加值
			if [ -z "$_add_env_current" ]; then
				_add_env_current="$_add_env_value"
			elif [ "$_add_env_mode" = "append" ]; then
				_add_env_current="$_add_env_current$_add_env_sep$_add_env_value"
			else
				_add_env_current="$_add_env_value$_add_env_sep$_add_env_current"
			fi
		done
		_add_env_tmpfile="${TMPDIR:-/tmp}/add_env_$$_$(date +%s)"
		printf 'export %s="%s"\n' "$_add_env_name" "$_add_env_current" >"$_add_env_tmpfile"
		. "$_add_env_tmpfile"
		rm -f "$_add_env_tmpfile"
		# 清理变量
		unset _add_env_mode _add_env_sep _add_env_name _add_env_current _add_env_value _add_env_temp _add_env_tmpfile
	}
fi

add_env PATH "$HOME/.local/bin"
export PATH
