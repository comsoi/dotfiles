# reset.sh
AUTO_THEME=$(qdbus org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read "org.freedesktop.appearance" "color-scheme" 2>/dev/null || echo "0")

if [ "$AUTO_THEME" != "1" ] && [ "$AUTO_THEME" != "2" ]; then
	_output=$(kreadconfig6 --group General --key ColorScheme)
	case "$_output" in
	*[Ll]ight*)
		AUTO_THEME=2
		;;
	*[Dd]ark*)
		AUTO_THEME=1
		;;
	esac
fi

if [ "$AUTO_THEME" = "1" ]; then
	(sleep 6 && bash "$HOME/.local/share/flatpak/exports/share/dark-mode.d/10-kde.sh" --no-restart) &
elif [ "$AUTO_THEME" = "2" ]; then
	(sleep 6 && bash "$HOME/.local/share/flatpak/exports/share/light-mode.d/10-kde.sh" --no-restart) &
fi
