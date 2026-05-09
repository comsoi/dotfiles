#!/bin/bash

mkdir -p ~/.local/state/wallpaper

cachefile="$HOME/.local/state/wallpaper/current_wallpaper"
rasifile="$HOME/.local/state/wallpaper/current_wallpaper.rasi"

blur="50x30"

# Get selected wallpaper
if [ -z $1 ]; then
	if [ -f $cachefile ]; then
		wallpaper=$(readlink -f $cachefile)
	fi
else
	wallpaper=$1
fi

ln -sf "$wallpaper" "$cachefile"

# set wallpaper
pcmanfm-qt -w "$wallpaper"

# gsettings get org.gnome.desktop.interface color-scheme for matugen
if [ "$(gsettings get org.gnome.desktop.interface color-scheme)" == "'prefer-light'" ]; then
	matugen --source-color-index 0 -t scheme-content -m light image "$wallpaper"
else
	matugen --source-color-index 0 -t scheme-content -m dark image "$wallpaper"
fi

# Created blurred wallpaper
blurredwallpaper="$HOME/.local/state/wallpaper/blurred_wallpaper.png"

magick $wallpaper -blur $blur $blurredwallpaper
# Create rasi file
echo "* { current-image: url(\"$blurredwallpaper\", height); }" > "$rasifile"

