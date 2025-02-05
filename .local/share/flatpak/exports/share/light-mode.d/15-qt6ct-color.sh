#!/usr/bin/env bash

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
KDE_GLOBALS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals"
New_Color_Scheme="LayanLight"
NEW_COLOR_SCHEME_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes/$New_Color_Scheme.colors"
NEW_ICON_THEME="Papirus-Light"
sed -i "s|^color_scheme_path=.*|color_scheme_path=${NEW_COLOR_SCHEME_PATH}|" "$CONFIG_FILE"
kwriteconfig6 --file kdeglobals --group General --key ColorScheme --type string "$New_Color_Scheme"
sed -i "s|^icon_theme=.*|icon_theme=${NEW_ICON_THEME}|" "$CONFIG_FILE"
kwriteconfig6 --file kdeglobals --group Icons --key Theme --type string "$NEW_ICON_THEME"
# Also can be done with:
# sed -i '/\[Icons\]/,/Theme=/{s/^Theme=.*/Theme='${NEW_ICON_THEME}'/}' "$KDE_GLOBALS_FILE"
