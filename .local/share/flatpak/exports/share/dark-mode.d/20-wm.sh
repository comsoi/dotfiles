#!/usr/bin/env bash

if ! systemctl --user --quiet is-active org.gnome.SettingsDaemon.Color.service || [[ "$XDG_CURRENT_DESKTOP" != "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
fi

dms ipc call theme dark
qs -c noctalia-shell ipc call darkMode setDark
waypaper --restore

