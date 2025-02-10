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

DESKTOP_THEME="Graphite-nord-light"

# WINDOW_DECORATIONS="Darkly"
WINDOW_DECORATIONS="kvantum"

QT_QPA_PLATFORMTHEME=$(systemctl --user show-environment | grep -oP '(?<=^QT_QPA_PLATFORMTHEME=).*')

if [[ ! "$QT_QPA_PLATFORMTHEME" =~ ^qt[56]ct$ ]]; then
	# Icons
	/usr/lib/plasma-changeicons --platform offscreen "$ICON_THEME"

	# Color Scheme
	plasma-apply-colorscheme --platform offscreen "$COLOR_SCHEME"

	# Plasma Style
	plasma-apply-desktoptheme --platform wayland "$DESKTOP_THEME" || plasma-apply-desktoptheme --platform minimal "$DESKTOP_THEME"

	# Windows Decorations
	kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle --type string "$WINDOW_DECORATIONS"
fi

if [[ "$1" != "--no-restart" ]] && [[ "$WINDOW_DECORATIONS" == "kvantum" ]]; then
	sleep 2
	kquitapp6 plasmashell
	kstart --platform offscreen plasmashell
fi
