#!/usr/bin/env bash

if ! systemctl --user --quiet is-active org.gnome.SettingsDaemon.Color.service || [[ "$XDG_CURRENT_DESKTOP" != "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
fi

dms ipc call theme light
qs -c noctalia-shell ipc call darkMode setLight
waypaper --restore
