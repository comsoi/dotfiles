# 00-reset.sh

(systemctl --user try-restart xdg-desktop-portal.service) &

if ! systemctl --user is-enabled --quiet darkman.service; then
	_output=$(kreadconfig6 --group General --key ColorScheme)
	case "$_output" in
	*[Ll]ight*)
		AUTO_THEME=2
		;;
	*[Dd]ark*)
		AUTO_THEME=1
		;;
	*)
		AUTO_THEME=2
		;;
	esac
	if [ "$AUTO_THEME" = "1" ]; then
		(sleep 6 && bash "$HOME/.local/share/flatpak/exports/share/dark-mode.d/10-kde.sh") &
	elif [ "$AUTO_THEME" = "2" ]; then
		(sleep 6 && bash "$HOME/.local/share/flatpak/exports/share/light-mode.d/10-kde.sh") &
	fi
fi
