#!/usr/bin/env bash

# Change the global Plasma Theme. On Manjaro you can use "org.manjaro.breath-dark.desktop"
# or you can create your own global Plasma Theme with the "Plasma Look And Feel Explorer".
# Reference: https://userbase.kde.org/Plasma/Create_a_Global_Theme_Package
#
# Since Plasma 5.26 the lookandfeeltool does not work anymore without "faking" the screen.
# Reference: https://bugs.kde.org/show_bug.cgi?id=460643

QT_QPA_PLATFORMTHEME=$(systemctl --user show-environment | grep -oP '(?<=^QT_QPA_PLATFORMTHEME=).*')

if [[ ! "$QT_QPA_PLATFORMTHEME" =~ ^qt[56]ct$ ]]; then
	# Icons
	/usr/lib/plasma-changeicons --platform offscreen WhiteSur-dark
	# Color Scheme
	plasma-apply-colorscheme --platform offscreen Layan
	# Plasma Style
	plasma-apply-desktoptheme --platform wayland Layan || plasma-apply-desktoptheme --platform minimal Layan
fi
