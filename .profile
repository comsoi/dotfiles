# ~/.profile

[ -z "$HOME" ] && exit

# add_env [-a|--append] [-i|--insert] [-s=SEP] VAR value...
# 默认前插（-i），所以同一条变量上后写的行优先级更高。
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

# ── 工具链安装位置 ──────────────────────────────────────────
export BUN_INSTALL="$HOME/.local/share/bun"
export BUN_INSTALL_BIN="$HOME/.local/bin/bun"
export UV_TOOL_BIN_DIR="$HOME/.local/bin/uv"

# ── 各家 agent 的数据目录（统一收进 ~/.local）───────────────
export CODEX_HOME="$HOME/.local/apps/codex"
export CLAUDE_CONFIG_DIR="$HOME/.local/apps/claude"
export DSH_HOME="$HOME/.local/apps/dsh"
export KIMI_CODE_HOME="$HOME/.local/apps/kimi-code"
export CUA_DRIVER_RS_HOME="$HOME/.local/opt/cua-driver"
export CUA_DRIVER_TELEMETRY_HOME="$HOME/.local/state/cua-driver"

# ── PATH ────────────────────────────────────────────────────
add_env PATH "$HOME/.local/bin"
add_env PATH "$HOME/.local/bin/agents"
add_env PATH "$HOME/.local/bin/bun"
add_env PATH "$HOME/.local/bin/games"
add_env PATH "$HOME/.local/bin/uv"
add_env PATH "$HOME/.local/bin/yazi"
add_env PATH "$HOME/.local/share/cargo/bin"
add_env PATH "$KIMI_CODE_HOME/bin"
export PATH

# ── 桌面环境 ────────────────────────────────────────────────
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
	export QT_QPA_PLATFORMTHEME=qt6ct
	crudini --set ~/.config/qt6ct/qt6ct.conf Appearance standard_dialogs xdgdesktopportal
fi

# ── JetBrains 系列统一 JDK ──────────────────────────────────
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

# ── 编辑器与渲染 ────────────────────────────────────────────
export EDITOR='nvim'
export LESS="-R"
export GSK_RENDERER=ngl
export ELECTRON_OZONE_PLATFORM_HINT=auto
export JDK_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

# ── Wine ────────────────────────────────────────────────────
# 禁止 wine 的 winemenubuilder 往 home 写菜单/图标/快捷方式（桌面集成）
export WINEDLLOVERRIDES="winemenubuilder.exe=d"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/wine"
