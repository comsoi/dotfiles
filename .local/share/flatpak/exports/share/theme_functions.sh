#!/usr/bin/env bash

_generate_scheme_paths() {
	local scheme="$1"
	local user_dir="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes"
	local system_dir="/usr/share/color-schemes"
	echo "${user_dir}/${scheme}.colors"
	echo "${system_dir}/${scheme}.colors"
}

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

check_icon_theme() {
	local theme="$1"
	if [[ -z "$theme" ]]; then
		echo "breeze"
		return 1
	fi

	if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/icons/$theme" ] || [ -d "/usr/share/icons/$theme" ]; then
		echo "$theme"
		return 0
	else
		echo "breeze"
		return 1
	fi
}

check_widget_style() {
	local style="$1"
	local default_style="breeze"

	if [[ -z "$style" ]]; then
		echo "$default_style"
		return 1
	fi

	if [[ "$style" =~ ^kvantum(-dark)?$ ]] && [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum" ]; then
		echo "$style"
		return 0
	elif [ "$style" = "Darkly" ] && [ -f "/usr/share/color-schemes/$style.colors" ]; then
		echo "$style"
		return 0
	else
		echo "$default_style"
		return 1
	fi
}

apply_theme_configuration() {
	local color_name icon_theme widget_style
	if [[ $# -eq 0 ]]; then
		echo "Usage: apply_theme_configuration [--color <name>] [--icon <theme>] [--style <widget>]" >&2
		return 1
	fi
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--color)
			color_name="$2"
			shift 2
			;;
		--icon)
			icon_theme="$2"
			shift 2
			;;
		--style)
			widget_style="$2"
			shift 2
			;;
		*)
			echo "Error: Unknown option '$1'" >&2
			echo "Usage: apply_theme_configuration [--color <name>] [--icon <theme>] [--style <widget>]" >&2
			return 1
			;;
		esac
	done
	echo "Applying theme configuration: color='$color_name', icon='$icon_theme', style='$widget_style'"

	local qt_config="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
	local kde_globals="${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals"

	local qt_config_exists=false
	if [[ -f "$qt_config" ]]; then
		qt_config_exists=true
	fi

	local can_use_kwriteconfig=false
	local platform_theme=$(systemctl --user show-environment 2>/dev/null | grep -oP '(?<=^QT_QPA_PLATFORMTHEME=).*' || echo "")
	if [[ "$platform_theme" =~ ^qt[56]ct$ ]] && command -v kwriteconfig6 >/dev/null; then
		can_use_kwriteconfig=true
		echo "KDE Globals update enabled."
	fi

	local color_path
	color_path=$(get_color_scheme_path "$color_name")
	if [[ -n "$color_path" ]]; then
		if "$qt_config_exists"; then
			sed -i "s|^color_scheme_path=.*|color_scheme_path=${color_path}|" "$qt_config"
		fi
		if "$can_use_kwriteconfig"; then
			kwriteconfig6 --file "$kde_globals" --group General --key ColorScheme "$color_name"
		fi
		echo "QT color scheme set to '$color_name' from '$color_path'."
	fi
	if check_icon_theme "$icon_theme"; then
		if "$qt_config_exists"; then
			sed -i "s|^icon_theme=.*|icon_theme=${icon_theme}|" "$qt_config"
		fi
		if "$can_use_kwriteconfig"; then
			kwriteconfig6 --file "$kde_globals" --group Icons --key Theme "$icon_theme"
		fi
		echo "QT icon theme set to '$icon_theme'."
	fi
	if check_widget_style "$widget_style"; then
		if "$qt_config_exists"; then
			sed -i "s|^style=.*|style=${widget_style}|" "$qt_config"
		fi
		if "$can_use_kwriteconfig"; then
			kwriteconfig6 --file "$kde_globals" --group KDE --key widgetStyle "$widget_style"
		fi
		echo "QT widget style set to '$widget_style'."
	fi
}
