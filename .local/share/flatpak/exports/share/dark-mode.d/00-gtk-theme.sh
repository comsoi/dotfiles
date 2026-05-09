#!/bin/sh

GTK_THEME="adw-gtk3-dark"
ICON_THEME="WhiteSur-dark"
USER_THEME="WhiteSur-Dark-solid"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.shell.extensions.user-theme name "$USER_THEME"

