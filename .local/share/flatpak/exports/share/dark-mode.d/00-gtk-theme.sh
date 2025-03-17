#!/bin/sh

GTK_THEME="Lavanda-Dark"
ICON_THEME="WhiteSur-dark"

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

$HOME/.config/hypr/scripts/gtk.sh
