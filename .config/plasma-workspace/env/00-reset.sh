#!/bin/sh

# ColorScheme reset
if ! systemctl --user --quiet is-enabled darkman.service; then
	_output=$(kreadconfig6 --group General --key ColorScheme)
	case "$_output" in
	*[Ll]ight*)
		AUTO_THEME=2
		;;
	*[Dd]ark*)
		AUTO_THEME=1
		;;
	esac
	if [ "$AUTO_THEME" = "1" ]; then
		(sleep 6 && bash "${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/exports/share/dark-mode.d/10-kde.sh") &
	elif [ "$AUTO_THEME" = "2" ]; then
		(sleep 6 && bash "${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/exports/share/light-mode.d/10-kde.sh") &
	fi
fi

# inputactions reset
ln -srf "${XDG_CONFIG_HOME:-$HOME/.config}/inputactions/config_kwin.yaml" "${XDG_CONFIG_HOME:-$HOME/.config}/inputactions/config.yaml"

