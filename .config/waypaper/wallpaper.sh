#!/bin/bash

mkdir -p ~/.local/state/wallpaper

waypaperrunning=$HOME/.local/state/wallpaper/waypaper-running
cachefile="$HOME/.local/state/wallpaper/current_wallpaper"
blurredwallpaper="$HOME/.local/state/wallpaper/blurred_wallpaper.png"
rasifile="$HOME/.local/state/wallpaper/current_wallpaper.rasi"

effect="off"
blur="50x30"

# Ensures that the script only run once if wallpaper effect enabled
if [ -f $waypaperrunning ]; then
	rm $waypaperrunning
	exit
fi

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z $1 ]; then
	if [ -f $cachefile ]; then
		wallpaper=$(readlink -f $cachefile)
	fi
else
	wallpaper=$1
fi
used_wallpaper=$wallpaper
echo ":: Setting wallpaper with source image $wallpaper"

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------
ln -sf "$wallpaper" "$cachefile"
echo ":: Path of current wallpaper linked to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------
wallpaperfilename=$(basename $wallpaper)
echo ":: Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Wallpaper Effects
# -----------------------------------------------------
if [ ! "$effect" == "off" ]; then
	# notify-send --replace-id=1 "Using wallpaper effect $effect..." "with image $wallpaperfilename" -h int:value:33
	source $HOME/.config/hypr/effects/wallpaper/$effect
	touch $waypaperrunning
	waypaper --wallpaper $used_wallpaper
else
	echo ":: Wallpaper effect is set to off"
fi

# post-process
wal -q -s -i "$used_wallpaper"
pywalfox update

pcmanfm-qt -w "$used_wallpaper"

systemctl --user reload waybar.service swaync.service

# -----------------------------------------------------
# Created blurred wallpaper
# -----------------------------------------------------
# notify-send --replace-id=1 "Generate new blurred version" "with blur $blur" -h int:value:66
magick $used_wallpaper -blur $blur $blurredwallpaper

# Create rasi file
echo "* { current-image: url(\"$blurredwallpaper\", height); }" > "$rasifile"

