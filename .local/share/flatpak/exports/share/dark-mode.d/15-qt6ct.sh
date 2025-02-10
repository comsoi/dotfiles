#!/usr/bin/env bash

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
KDE_GLOBALS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals"

NEW_COLOR_SCHEME="GraphiteNordDark"
NEW_COLOR_SCHEME_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes/$NEW_COLOR_SCHEME.colors"
NEW_ICON_THEME="Papirus-Dark"
NEW_WIDGET_STYLE="kvantum-dark"

QT_QPA_PLATFORMTHEME=$(systemctl --user show-environment | grep -oP '(?<=^QT_QPA_PLATFORMTHEME=).*')

# color-schemes
sed -i "s|^color_scheme_path=.*|color_scheme_path=${NEW_COLOR_SCHEME_PATH}|" "$CONFIG_FILE"
# icon-theme
sed -i "s|^icon_theme=.*|icon_theme=${NEW_ICON_THEME}|" "$CONFIG_FILE"
# widget-style
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle --type string "$NEW_WIDGET_STYLE"
#for KDE apps
if [[ "$QT_QPA_PLATFORMTHEME" =~ ^qt[56]ct$ ]]; then
	kwriteconfig6 --file kdeglobals --group General --key ColorScheme --type string "$NEW_COLOR_SCHEME"
	kwriteconfig6 --file kdeglobals --group Icons --key Theme --type string "$NEW_ICON_THEME"
fi
