#!/usr/bin/env bash

# Change the global Plasma Theme. On Manjaro you can use "org.manjaro.breath-dark.desktop"
# or you can create your own global Plasma Theme with the "Plasma Look And Feel Explorer".
# Reference: https://userbase.kde.org/Plasma/Create_a_Global_Theme_Package
#
# Since Plasma 5.26 the lookandfeeltool does not work anymore without "faking" the screen.
# Reference: https://bugs.kde.org/show_bug.cgi?id=460643

systemctl --user --quiet is-active plasma-plasmashell.service || [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || exit 0

source "$(dirname "$(realpath "$0")")/../theme_functions.sh"

DESKTOP_THEME="Colloid-dark-nord"

# COLOR_SCHEME="FlatRemixBlueDark"
COLOR_SCHEME="ColloidDarkNord"

WIDGET_STYLE="Darkly"

# ICON_THEME="WhiteSur-dark"
ICON_THEME="Colloid-Catppuccin-Dark"

# Plasma Style
plasma-apply-desktoptheme --platform wayland "$DESKTOP_THEME" || plasma-apply-desktoptheme --platform minimal "$DESKTOP_THEME"

# Color Scheme
plasma-apply-colorscheme --platform offscreen "$COLOR_SCHEME"

# Widget Style
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle --type string "$(check_widget_style "$WIDGET_STYLE")"

# Icons
/usr/lib/plasma-changeicons --platform offscreen "$(check_icon_theme "$ICON_THEME")"

