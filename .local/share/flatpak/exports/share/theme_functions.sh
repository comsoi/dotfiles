#!/usr/bin/env bash
# theme_functions.sh - 桌面主题管理工具函数库

# 生成颜色方案的可能文件路径
_generate_scheme_paths() {
	local scheme="$1"
	local user_dir="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes"
	local system_dir="/usr/share/color-schemes"
	echo "${user_dir}/${scheme}.colors"
	echo "${system_dir}/${scheme}.colors"
}

# 检查颜色方案是否存在，不存在则返回适当的默认方案
check_color_scheme() {
	local scheme="$1"
	local found=false

	# 检查指定方案是否存在
	while IFS= read -r path; do
		if [[ -f "$path" ]]; then
			echo "$scheme"
			return 0
		fi
	done < <(_generate_scheme_paths "$scheme")

	# 如果没找到，根据名称选择默认方案
	local scheme_lower="${scheme,,}"
	case "$scheme_lower" in
	*light*)
		scheme=BreezeLight
		;;
	*dark*)
		scheme=BreezeDark
		;;
	*)
		scheme=BreezeClassic
		;;
	esac
	echo "$scheme"
}

# 获取颜色方案文件的完整路径
get_color_scheme_path() {
	local scheme="$1"

	while IFS= read -r path; do
		if [[ -f "$path" ]]; then
			echo "$path"
			return 0
		fi
	done < <(_generate_scheme_paths "$scheme")
	return 1
}

# 检查图标主题是否存在
check_icon_theme() {
	local theme="$1"
	if [[ -z "$theme" ]]; then
		echo "breeze"
		return
	fi

	if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/icons/$theme" ] || [ -d "/usr/share/icons/$theme" ]; then
		echo "$theme"
	else
		echo "breeze"
	fi
}

# 检查小部件风格是否存在
check_widget_style() {
	local style="$1"
	local default_style="breeze"

	if [[ -z "$style" ]]; then
		echo "$default_style"
		return
	fi

	if [[ "$style" =~ ^kvantum(-dark)?$ ]] && [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum" ]; then
		echo "$style"
	elif [ "$style" = "Darkly" ] && [ -f "/usr/share/color-schemes/$style.colors" ]; then
		echo "$style"
	else
		echo "$default_style"
	fi
}

# 检查桌面主题是否存在
check_desktop_theme() {
	local theme="$1"
	if [[ -z "$theme" ]]; then
		echo "default"
		return
	fi

	if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/plasma/desktoptheme/$theme" ] || [ -d "/usr/share/plasma/desktoptheme/$theme" ]; then
		echo "$theme"
	else
		echo "default"
	fi
}

# 应用主题配置到系统
apply_theme_configuration() {
	local color_name="$1"
	local icon_theme="$2"
	local widget_style="$3"

	# 检查必要的参数
	if [[ -z "$color_name" ]]; then
		echo "错误: 必须提供颜色方案名称" >&2
		return 1
	fi

	# 配置文件路径
	local qt_config="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
	local kde_config="${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals"

	# 检查平台主题环境变量
	local platform_theme=$(systemctl --user show-environment 2>/dev/null | grep -oP '(?<=^QT_QPA_PLATFORMTHEME=).*' || echo "")

	# 获取颜色方案路径
	local color_path=$(get_color_scheme_path "$color_name")
	if [[ -z "$color_path" ]]; then
		echo "错误: 无法找到颜色方案 '$color_name' 的路径" >&2
		return 1
	fi

	# 应用配置到QT6CT
	if [[ -f "$qt_config" ]]; then
		sed -i "s|^color_scheme_path=.*|color_scheme_path=${color_path}|" "$qt_config"

		if [[ -n "$icon_theme" ]]; then
			sed -i "s|^icon_theme=.*|icon_theme=${icon_theme}|" "$qt_config"
		fi

		if [[ -n "$widget_style" ]]; then
			sed -i "s|^style=.*|style=${widget_style}|" "$qt_config"
		fi
	else
		echo "警告: QT6CT配置文件不存在: $qt_config" >&2
	fi

	# 应用配置到KDE全局设置
	if [[ "$platform_theme" =~ ^qt[56]ct$ ]] && command -v kwriteconfig6 >/dev/null; then
		kwriteconfig6 --file "$kde_config" \
			--group KDE --key widgetStyle "$widget_style" \
			--group General --key ColorScheme "$color_name" \
			--group Icons --key Theme "$icon_theme"
	fi

	# 输出配置信息
	echo "已应用主题配置:"
	echo " - 颜色方案: $color_name ($color_path)"
	[[ -n "$icon_theme" ]] && echo " - 图标主题: $icon_theme"
	[[ -n "$widget_style" ]] && echo " - 小部件风格: $widget_style"
	[[ "$platform_theme" =~ ^qt[56]ct$ ]] && echo " - KDE 全局设置已更新"

	return 0
}
