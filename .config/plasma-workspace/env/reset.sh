# reset.sh

unset QT_QPA_PLATFORMTHEME
unset QT_IM_MODULE

systemctl --user unset-environment QT_QPA_PLATFORMTHEME
systemctl --user unset-environment QT_IM_MODULE

systemctl --user daemon-reload

(sleep 1 && systemctl --user restart xdg-desktop-portal.service) &

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
unset _output

if [ "$AUTO_THEME" = "1" ]; then
	(sleep 6 && bash "$HOME/.local/share/flatpak/exports/share/dark-mode.d/10-kde.sh" --no-restart) &
elif [ "$AUTO_THEME" = "2" ]; then
	(sleep 6 && bash "$HOME/.local/share/flatpak/exports/share/light-mode.d/10-kde.sh" --no-restart) &
fi
