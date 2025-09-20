#!/bin/sh

prefer_theme=$(qdbus org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read "org.freedesktop.appearance" "color-scheme" 2>/dev/null || echo "0")

if [ $prefer_theme = 2 ]; then
	style="style-light.css"
else
	style="style-dark.css"
fi

nwg-dock-hyprland -d -i 48 -w 5 -mb 10 -ml 10 -mr 10 -s $style -c "rofi -show drun"
