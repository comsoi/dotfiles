#!/usr/bin/env bash

source "$(dirname "$(realpath "$0")")/../theme_functions.sh"

NEW_ICON_THEME="Papirus-Light"
NEW_WIDGET_STYLE="Darkly"

NEW_COLOR_SCHEME="GraphiteNordLight"
NEW_ICON_THEME="Tela-light"
NEW_WIDGET_STYLE="kvantum"

apply_theme_configuration \
	"$(check_color_scheme "$NEW_COLOR_SCHEME")" \
	"$(check_icon_theme "$NEW_ICON_THEME")" \
	"$(check_widget_style "$NEW_WIDGET_STYLE")"

