# ~/.profile

[ -z "$HOME" ] && exit

add_env() {
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
		echo "Unsupported shell. Only Bash and Zsh are supported." >&2
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

	if printf -v "$env_name" %s "$current_val" > /dev/null 2>&1; then
		export "$env_name"
	fi
}

add_env PATH "$HOME/.local/bin"
add_env PATH "$HOME/.local/share/cargo/bin"
add_env PATH "$HOME/.cache/.bun/bin"
export PATH

if [[ $(tty) == /dev/tty9 ]]; then
	export LANG=zh_CN.UTF-8
	export XDG_CURRENT_DESKTOP=GNOME
fi

if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
	if [ "$(cat /sys/class/drm/card1/*HDMI*/status)" = "disconnected" ]; then
		export __EGL_VENDOR_LIBRARY_FILENAMES="/usr/share/glvnd/egl_vendor.d/50_mesa.json"
		export VK_DRIVER_FILES="/usr/share/vulkan/icd.d/intel_icd.x86_64.json"
	fi
	export QT_WAYLAND_DECORATION=adwaita
	export QT_QPA_PLATFORMTHEME=qt5ct
	crudini --set ~/.config/qt6ct/qt6ct.conf Appearance standard_dialogs xdgdesktopportal
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

export EDITOR='nvim'
export LESS="-R"
export GSK_RENDERER=ngl
export ELECTRON_OZONE_PLATFORM_HINT=auto
export JDK_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/wine"
export CODEX_HOME="$HOME"/.local/apps/codex

