#!/usr/bin/env bash

# Change the global Plasma Theme. On Manjaro you can use "org.manjaro.breath-dark.desktop"
# or you can create your own global Plasma Theme with the "Plasma Look And Feel Explorer".
# Reference: https://userbase.kde.org/Plasma/Create_a_Global_Theme_Package
#
# Since Plasma 5.26 the lookandfeeltool does not work anymore without "faking" the screen.
# Reference: https://bugs.kde.org/show_bug.cgi?id=460643

XDG_CURRENT_DESKTOP=$(systemctl --user show-environment | grep -oP '(?<=^XDG_CURRENT_DESKTOP=).*')

[[ $XDG_CURRENT_DESKTOP != "KDE" ]] && exit 0

source "$(dirname "$(realpath "$0")")/../theme_functions.sh"

# ICON_THEME="WhiteSur-dark"
ICON_THEME="Colloid-Catppuccin-Dark"

# COLOR_SCHEME="FlatRemixBlueDark"
COLOR_SCHEME="ColloidDarkNord"

WIDGET_STYLE="Darkly"
DESKTOP_THEME="Colloid-dark-nord"

# Icons
/usr/lib/plasma-changeicons --platform offscreen "$(check_icon_theme "$ICON_THEME")"

# Color Scheme
plasma-apply-colorscheme --platform offscreen "$(check_color_scheme "$COLOR_SCHEME")"

# Widget Style
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle --type string "$(check_widget_style "$WIDGET_STYLE")"

# Plasma Style
DESKTOP_THEME="$(check_desktop_theme "$DESKTOP_THEME")"
plasma-apply-desktoptheme --platform wayland "$DESKTOP_THEME" || plasma-apply-desktoptheme --platform minimal "$DESKTOP_THEME"
