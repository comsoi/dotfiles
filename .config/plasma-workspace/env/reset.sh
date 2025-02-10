#! /usr/bin/bash

systemctl --user unset-environment QT_QPA_PLATFORMTHEME
systemctl --user daemon-reload

AUTO_THEME=$(cat ~/.cache/darkman/mode.txt)
if [[ "$AUTO_THEME" == "dark" ]]; then
	"$HOME/.local/share/flatpak/exports/share/dark-mode.d/10-kde-color.sh" --no-restart
elif [[ "$AUTO_THEME" == "light" ]]; then
	"$HOME/.local/share/flatpak/exports/share/light-mode.d/10-kde-color.sh" --no-restart
fi
