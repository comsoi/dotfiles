#!/usr/bin/env bash
systemctl --user unset-environment QT_QPA_PLATFORMTHEME
AUTO_THEME=$(qdbus org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read "org.freedesktop.appearance" "color-scheme")
if [ "$AUTO_THEME" = "1" ]; then
	export XDG_CURRENT_DESKTOP=KDE
	"$HOME/.local/share/flatpak/exports/share/dark-mode.d/10-kde.sh" --no-restart
elif [ "$AUTO_THEME" = "2" ]; then
	export XDG_CURRENT_DESKTOP=KDE
	"$HOME/.local/share/flatpak/exports/share/light-mode.d/10-kde.sh" --no-restart
fi
