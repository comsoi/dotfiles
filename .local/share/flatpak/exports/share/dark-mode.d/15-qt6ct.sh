#!/usr/bin/env bash

source "$(dirname "$(realpath "$0")")/../theme_functions.sh"

NEW_ICON_THEME="Papirus-Dark"
NEW_WIDGET_STYLE="Darkly"

NEW_COLOR_SCHEME="GraphiteNordDark"
NEW_ICON_THEME="Tela-dark"
NEW_WIDGET_STYLE="kvantum-dark"
NEW_KVANTUM_THEME="ColloidNordDark"

apply_theme_configuration \
	--color "$NEW_COLOR_SCHEME" \
	--icon "$NEW_ICON_THEME" \
	--style "$NEW_WIDGET_STYLE"
kvantummanager --set "$NEW_KVANTUM_THEME"
crudini --set ~/.config/qt6ct/qt6ct.conf Appearance custom_palette true
