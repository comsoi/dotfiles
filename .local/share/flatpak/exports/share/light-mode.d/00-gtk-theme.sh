#!/bin/sh

GTK_THEME="Lavanda-Sea-Light"
ICON_THEME="WhiteSur-light"
USER_THEME="WhiteSur-Light-solid"

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.shell.extensions.user-theme name "$USER_THEME"

$HOME/.config/hypr/scripts/gtk.sh

# for gtk apps
if ! systemctl --user --quiet is-active org.gnome.SettingsDaemon.Color.service || [[ "$XDG_CURRENT_DESKTOP" != "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
fi

