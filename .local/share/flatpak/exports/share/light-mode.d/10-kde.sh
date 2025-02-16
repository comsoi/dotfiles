#!/usr/bin/env bash

# Change the global Plasma Theme. On Manjaro you can use "org.manjaro.breath-dark.desktop"
# or you can create your own global Plasma Theme with the "Plasma Look And Feel Explorer".
# Reference: https://userbase.kde.org/Plasma/Create_a_Global_Theme_Package
#
# Since Plasma 5.26 the lookandfeeltool does not work anymore without "faking" the screen.
# Reference: https://bugs.kde.org/show_bug.cgi?id=460643

# ICON_THEME="WhiteSur-light"
ICON_THEME="Colloid-Catppuccin-Light"

# COLOR_SCHEME="FlatRemixBlueLight"
COLOR_SCHEME="GraphiteNordLight"

# DESKTOP_THEME="Graphite-nord-light"
DESKTOP_THEME="Colloid-light-nord"

WINDOW_DECORATIONS="kvantum"
WINDOW_DECORATIONS="Darkly"

XDG_CURRENT_DESKTOP=$(systemctl --user show-environment | grep -oP '(?<=^XDG_CURRENT_DESKTOP=).*')

[[ $XDG_CURRENT_DESKTOP != "KDE" ]] && exit 0

# Icons
/usr/lib/plasma-changeicons --platform offscreen "$ICON_THEME"

# Color Scheme
plasma-apply-colorscheme --platform offscreen "$COLOR_SCHEME"

# Plasma Style
plasma-apply-desktoptheme --platform wayland "$DESKTOP_THEME" || plasma-apply-desktoptheme --platform minimal "$DESKTOP_THEME"

# Windows Decorations
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle --type string "$WINDOW_DECORATIONS"

if [[ "$1" != "--no-restart" ]]; then
	sleep 2
	kquitapp6 plasmashell
	kstart --platform offscreen plasmashell
fi
