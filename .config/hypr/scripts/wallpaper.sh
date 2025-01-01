#!/bin/bash
#                _ _
# __      ____ _| | |_ __   __ _ _ __   ___ _ __
# \ \ /\ / / _` | | | '_ \ / _` | '_ \ / _ \ '__|
#  \ V  V / (_| | | | |_) | (_| | |_) |  __/ |
#   \_/\_/ \__,_|_|_| .__/ \__,_| .__/ \___|_|
#                   |_|         |_|
#
# -----------------------------------------------------
# Check to use wallpaper cache
# -----------------------------------------------------

use_cache=0
if [ -f ~/.config/hypr/settings/wallpaper_cache ] ;then
    use_cache=1
fi

if [ "$use_cache" == "1" ] ;then
    echo ":: Using Wallpaper Cache"
else
    echo ":: Wallpaper Cache disabled"
fi

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

force_generate=0
generated_versions="$HOME/.config/hypr/cache/wallpaper-generated"
waypaper_running=$HOME/.config/hypr/cache/waypaper-running
cache_file="$HOME/.config/hypr/cache/current_wallpaper"
blurred_wallpaper="$HOME/.config/hypr/cache/blurred_wallpaper.png"
square_wallpaper="$HOME/.config/hypr/cache/square_wallpaper.png"
rasi_file="$HOME/.config/hypr/cache/current_wallpaper.rasi"
blur_file="$HOME/.config/hypr/settings/blur.sh"
default_wallpaper="$HOME/.config/hypr/wallpaper.jpg"
blur="50x30"
blur=$(cat $blur_file)

if [ -f $waypaper_running ] ;then
    rm $waypaper_running
    exit
else
    touch $waypaper_running
fi

# Create folder with generated versions of wallpaper if not exists
if [ ! -d $generated_versions ] ;then
    mkdir $generated_versions
fi

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z $1 ] ;then
    if [ -f $cache_file ] ;then
        wallpaper=$(cat $cache_file)
    else
        wallpaper=$default_wallpaper
    fi
else
    wallpaper=$1
fi

echo $wallpaper > $cache_file

used_wallpaper=$wallpaper
echo ":: Setting wallpaper with original image $wallpaper"
tmp_wallpaper=$wallpaper

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------

if [ ! -f $cache_file ] ;then
    touch $cache_file
fi
echo "$wallpaper" > $cache_file
echo ":: Path of current wallpaper copied to $cache_file"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------
wallpaper_filename=$(basename $wallpaper)
echo ":: Wallpaper Filename: $wallpaper_filename"

# -----------------------------------------------------
# Execute pywal
# -----------------------------------------------------

echo ":: Execute pywal with $used_wallpaper"
wal -q -i $used_wallpaper
#source "$HOME/.cache/wal/colors.sh"

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------
~/.config/waybar/launch.sh

# -----------------------------------------------------
# Reload AGS
# -----------------------------------------------------
killall ags
ags &

# -----------------------------------------------------
# Created blurred wallpaper
# -----------------------------------------------------

echo ":: Generate new cached wallpaper blur-$blur-$wallpaper_filename with blur $blur"
magick $used_wallpaper -resize 75% $blurred_wallpaper
echo ":: Resized to 75%"
if [ ! "$blur" == "0x0" ] ;then
    magick $blurred_wallpaper -blur $blur $blurred_wallpaper
    cp $blurred_wallpaper $generated_versions/blur-$blur-$wallpaper_filename.png
    echo ":: Blurred"
fi
cp $generated_versions/blur-$blur-$wallpaper_filename.png $blurred_wallpaper

# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------

if [ ! -f $rasi_file ] ;then
    touch $rasi_file
fi
echo "* { current-image: url(\"$blurred_wallpaper\", height); }" > "$rasi_file"

# -----------------------------------------------------
# Created square wallpaper
# -----------------------------------------------------

echo ":: Generate new cached wallpaper square-$wallpaper_filename"
magick $tmp_wallpaper -gravity Center -extent 1:1 $square_wallpaper
cp $square_wallpaper $generated_versions/square-$wallpaper_filename.png