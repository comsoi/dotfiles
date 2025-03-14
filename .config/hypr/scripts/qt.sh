#! /usr/bin/bash

AUTO_THEME=$(cat ~/.cache/darkman/mode.txt)
if [[ "$AUTO_THEME" == "dark" ]]; then
	"$HOME/.local/share/flatpak/exports/share/dark-mode.d/15-qt6ct.sh"
elif [[ "$AUTO_THEME" == "light" ]]; then
	"$HOME/.local/share/flatpak/exports/share/light-mode.d/15-qt6ct.sh"
fi
