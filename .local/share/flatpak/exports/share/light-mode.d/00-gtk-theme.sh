#!/bin/sh

GTK_THEME="Lavanda-Sea-Light"
ICON_THEME="WhiteSur-light"

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface color-scheme "prefer-light"

$HOME/.config/hypr/scripts/gtk.sh
