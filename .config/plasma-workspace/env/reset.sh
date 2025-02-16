#! /usr/bin/bash

systemctl --user unset-environment QT_QPA_PLATFORMTHEME
systemctl --user daemon-reload

AUTO_THEME=$(cat ~/.cache/darkman/mode.txt)
DM_PATH=$(grep -oP '(?<=^ExecStart=).*' /etc/systemd/system/display-manager.service 2>/dev/null)

if [[ "$DM_PATH" == "/usr/bin/gdm" ]]; then
	source "/etc/profile"
	source "$HOME/.bash_profile"
fi

if [[ "$AUTO_THEME" == "dark" ]]; then
	(sleep 5 && "$HOME/.local/share/flatpak/exports/share/dark-mode.d/10-kde.sh" --no-restart) &
elif [[ "$AUTO_THEME" == "light" ]]; then
	(sleep 5 && "$HOME/.local/share/flatpak/exports/share/light-mode.d/10-kde.sh" --no-restart) &
fi
