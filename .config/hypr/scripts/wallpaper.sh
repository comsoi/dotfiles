#!/bin/bash
#  _      __     ____
# | | /| / /__ _/ / /__  ___ ____  ___ ____
# | |/ |/ / _ `/ / / _ \/ _ `/ _ \/ -_) __/
# |__/|__/\_,_/_/_/ .__/\_,_/ .__/\__/_/
#                /_/       /_/
# -----------------------------------------------------
# Check to use wallpaper cache
# -----------------------------------------------------

if [ -f ~/.local/state/wallpaper/wallpaper_cache ]; then
	use_cache=1
	echo ":: Using Wallpaper Cache"
else
	use_cache=0
	echo ":: Wallpaper Cache disabled"
fi

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

force_generate=0
generatedversions="$HOME/.local/state/wallpaper/wallpaper-generated"
waypaperrunning=$HOME/.local/state/wallpaper/waypaper-running
cachefile="$HOME/.local/state/wallpaper/current_wallpaper"
blurredwallpaper="$HOME/.local/state/wallpaper/blurred_wallpaper.png"
squarewallpaper="$HOME/.local/state/wallpaper/square_wallpaper.png"
rasifile="$HOME/.local/state/wallpaper/current_wallpaper.rasi"

defaultwallpaper=""

blur="50x30"

# Ensures that the script only run once if wallpaper effect enabled
if [ -f $waypaperrunning ]; then
	rm $waypaperrunning
	exit
fi

# Create folder with generated versions of wallpaper if not exists
if [ ! -d $generatedversions ]; then
	mkdir $generatedversions
fi

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z $1 ]; then
	if [ -f $cachefile ]; then
		wallpaper=$(cat $cachefile)
	else
		wallpaper=$defaultwallpaper
	fi
else
	wallpaper=$1
fi
used_wallpaper=$wallpaper
echo ":: Setting wallpaper with source image $wallpaper"
tmpwallpaper=$wallpaper

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------

if [ ! -f $cachefile ]; then
	touch $cachefile
fi
echo "$wallpaper" >$cachefile
echo ":: Path of current wallpaper copied to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------
wallpaperfilename=$(basename $wallpaper)
echo ":: Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Wallpaper Effects
# -----------------------------------------------------

effect="off"
if [ ! "$effect" == "off" ]; then
	used_wallpaper=$generatedversions/$effect-$wallpaperfilename
	if [ -f $generatedversions/$effect-$wallpaperfilename ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
		echo ":: Use cached wallpaper $effect-$wallpaperfilename"
	else
		echo ":: Generate new cached wallpaper $effect-$wallpaperfilename with effect $effect"
		notify-send --replace-id=1 "Using wallpaper effect $effect..." "with image $wallpaperfilename" -h int:value:33
		source $HOME/.config/hypr/effects/wallpaper/$effect
	fi
	echo ":: Loading wallpaper $generatedversions/$effect-$wallpaperfilename with effect $effect"
	echo ":: Setting wallpaper with $used_wallpaper"
	touch $waypaperrunning
	waypaper --wallpaper $used_wallpaper
else
	echo ":: Wallpaper effect is set to off"
fi

# -----------------------------------------------------
# Execute pywal
# -----------------------------------------------------

echo ":: Execute pywal with $used_wallpaper"
wal -q -s -i "$used_wallpaper"

if systemctl --user is-active --quiet waybar.service; then
	systemctl --user restart waybar.service
fi

pywalfox update

swaync-client -rs

# -----------------------------------------------------
# Created blurred wallpaper
# -----------------------------------------------------

if [ -f $generatedversions/blur-$blur-$effect-$wallpaperfilename.png ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
	echo ":: Use cached wallpaper blur-$blur-$effect-$wallpaperfilename"
else
	echo ":: Generate new cached wallpaper blur-$blur-$effect-$wallpaperfilename with blur $blur"
	# notify-send --replace-id=1 "Generate new blurred version" "with blur $blur" -h int:value:66
	magick $used_wallpaper -resize 75% $blurredwallpaper
	echo ":: Resized to 75%"
	if [ ! "$blur" == "0x0" ]; then
		magick $blurredwallpaper -blur $blur $blurredwallpaper
		cp $blurredwallpaper $generatedversions/blur-$blur-$effect-$wallpaperfilename.png
		echo ":: Blurred"
	fi
fi
cp $generatedversions/blur-$blur-$effect-$wallpaperfilename.png $blurredwallpaper

# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------

if [ ! -f $rasifile ]; then
	touch $rasifile
fi
echo "* { current-image: url(\"$blurredwallpaper\", height); }" >"$rasifile"

# -----------------------------------------------------
# Created square wallpaper
# -----------------------------------------------------

echo ":: Generate new cached wallpaper square-$wallpaperfilename"
magick $tmpwallpaper -gravity Center -extent 1:1 $squarewallpaper
cp $squarewallpaper $generatedversions/square-$wallpaperfilename.png
