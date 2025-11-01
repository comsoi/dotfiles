# ~/.profile

[ -z "$HOME" ] && exit

export EDITOR='nvim'
export LESS="-R"

export GSK_RENDERER=ngl

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	# export _JAVA_AWT_WM_NONREPARENTING=1
	export ELECTRON_OZONE_PLATFORM_HINT=auto
fi

if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
	if [ "$(cat /sys/class/drm/card1/*HDMI*/status)" = "disconnected" ]; then
		export __EGL_VENDOR_LIBRARY_FILENAMES="/usr/share/glvnd/egl_vendor.d/50_mesa.json"
		export VK_DRIVER_FILES="/usr/share/vulkan/icd.d/intel_icd.x86_64.json"
	fi
	export QT_QPA_PLATFORMTHEME=qt5ct
	export QT_WAYLAND_DECORATION=adwaita
fi

if [ -d "/usr/lib/jvm/jre-jetbrains" ]; then
	export IDEA_JDK=/usr/lib/jvm/jre-jetbrains
	export PHPSTORM_JDK=/usr/lib/jvm/jre-jetbrains
	export WEBIDE_JDK=/usr/lib/jvm/jre-jetbrains
	export PYCHARM_JDK=/usr/lib/jvm/jre-jetbrains
	export RUBYMINE_JDK=/usr/lib/jvm/jre-jetbrains
	export CLION_JDK=/usr/lib/jvm/jre-jetbrains
	export DATAGRIP_JDK=/usr/lib/jvm/jre-jetbrains
	export GOLAND_JDK=/usr/lib/jvm/jre-jetbrains
	export STUDIO_JDK=/usr/lib/jvm/jre-jetbrains
	export RUSTROVER_JDK=/usr/lib/jvm/jre-jetbrains
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
		[[ $# -lt 1 ]] && return 1
		local env_name current_val value_to_add mode="insert" sep=":"

		while [[ $# -gt 0 ]]; do
			case "$1" in
				-a|--append) mode=append; shift ;;
				-i|--insert) mode=insert; shift ;;
				-s=*|--sep=*) sep="${1#*=}"; shift ;;
				*) env_name="$1"; shift; break ;;
			esac
		done

		if [[ -n "$ZSH_VERSION" ]]; then
			current_val="${(P)env_name}"
		elif [[ -n "$BASH_VERSION" ]]; then
			current_val="${!env_name}"
		else
			echo "add_env: Error: Unsupported shell." >&2
			return 1
		fi

		for value_to_add in "$@"; do
			[[ -z "$value_to_add" ]] && continue
			if [[ "$sep$current_val$sep" == *"$sep$value_to_add$sep"* ]]; then
				continue
			fi
			if [[ "$mode" == "append" ]]; then
				current_val="${current_val:+$current_val$sep}$value_to_add"
			else
				current_val="$value_to_add${current_val:+$sep$current_val}"
			fi
		done

		if printf -v "$env_name" %s "$current_val"; then
			export "$env_name"
		else
			echo "add_env: Error: Failed to set environment variable '$env_name'." >&2
			return 1
		fi
		return 0
	}
else
	add_env() {
		[ $# -lt 1 ] && return 1
		_add_env_mode="insert"
		_add_env_sep=":"
		_add_env_name=""
		_add_env_current=""
		_add_env_value=""
		_add_env_temp=""

		while [ $# -gt 0 ]; do
			case "$1" in
				-a|--append) _add_env_mode=append; shift ;;
				-i|--insert) _add_env_mode=insert; shift ;;
				-s=*|--sep=*) sep="${1#*=}"; shift ;;
				*) _add_env_name="$1"; shift; break ;;
			esac
		done

		_add_env_current=$(printenv "$_add_env_name" 2>/dev/null) || _add_env_current=""

		for _add_env_value in "$@"; do
			[ -z "$_add_env_value" ] && continue
			_add_env_temp="$_add_env_sep$_add_env_current$_add_env_sep"
			case "$_add_env_temp" in
			*"$_add_env_sep$_add_env_value$_add_env_sep"*) continue ;;
			esac
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
		unset _add_env_mode _add_env_sep _add_env_name _add_env_current _add_env_value _add_env_temp _add_env_tmpfile
	}
fi

add_env PATH "$HOME/.local/bin"
add_env PATH "$HOME/.local/share/cargo/bin"
export PATH
