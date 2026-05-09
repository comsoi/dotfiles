#!/usr/bin/env bash

source "$(dirname "$(realpath "$0")")/../theme_functions.sh"

NEW_ICON_THEME="Tela-dark"

NEW_WIDGET_STYLE="kvantum-dark"
NEW_COLOR_SCHEME="LibadwaitaDark"
NEW_KVANTUM_THEME="KvLibadwaitaDark"

NEW_WIDGET_STYLE="Darkly"
NEW_COLOR_SCHEME="MatugenDark"

apply_theme_configuration \
	--color "$NEW_COLOR_SCHEME" \
	--icon "$NEW_ICON_THEME" \
	--style "$NEW_WIDGET_STYLE"
kvantummanager --set "$NEW_KVANTUM_THEME"
