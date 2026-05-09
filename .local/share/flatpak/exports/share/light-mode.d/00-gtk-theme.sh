#!/bin/sh

GTK_THEME="adw-gtk3"
ICON_THEME="WhiteSur-light"
USER_THEME="WhiteSur-Light-solid"

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.shell.extensions.user-theme name "$USER_THEME"

