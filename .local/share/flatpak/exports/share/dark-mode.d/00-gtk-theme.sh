#!/bin/sh

GTK_THEME="Lavanda-Dark"
ICON_THEME="WhiteSur-dark"
USER_THEME="WhiteSur-Dark-solid"

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.shell.extensions.user-theme name "$USER_THEME"

$HOME/.config/hypr/scripts/gtk.sh

if ! systemctl --user --quiet is-active org.gnome.SettingsDaemon.Color.service || [[ "$XDG_CURRENT_DESKTOP" != "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
fi

