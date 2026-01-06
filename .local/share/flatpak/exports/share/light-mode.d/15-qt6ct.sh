#!/usr/bin/env bash

source "$(dirname "$(realpath "$0")")/../theme_functions.sh"

NEW_ICON_THEME="Papirus-Light"
NEW_WIDGET_STYLE="Darkly"

NEW_COLOR_SCHEME="GraphiteNordLight"
NEW_ICON_THEME="Tela-light"
NEW_WIDGET_STYLE="kvantum"
NEW_KVANTUM_THEME="ColloidNord"

apply_theme_configuration \
	--color "$NEW_COLOR_SCHEME" \
	--icon "$NEW_ICON_THEME" \
	--style "$NEW_WIDGET_STYLE"
kvantummanager --set "$NEW_KVANTUM_THEME"
crudini --set ~/.config/qt6ct/qt6ct.conf Appearance custom_palette true
