#!/bin/bash
#     _         _         __        ______
#    / \  _   _| |_ ___   \ \      / /  _ \
#   / _ \| | | | __/ _ \   \ \ /\ / /| |_) |
#  / ___ \ |_| | || (_) |   \ V  V / |  __/
# /_/   \_\__,_|\__\___/     \_/\_/  |_|
#

sec=300

_setWallpaperRandomly() {
	waypaper --random
	sleep $sec
	_setWallpaperRandomly
}

if [ ! -f ~/.local/state/wallpaper/wallpaper-automation ]; then
	touch ~/.local/state/wallpaper/wallpaper-automation
	echo ":: Start wallpaper automation script"
	notify-send "Wallpaper automation process started" "Wallpaper will be changed every $sec seconds."
	_setWallpaperRandomly
else
	rm ~/.local/state/wallpaper/wallpaper-automation
	notify-send "Wallpaper automation process stopped."
	echo ":: Wallpaper automation script process $wp stopped"
	wp=$(pgrep -f wallpaper-automation.sh)
	kill -KILL $wp
fi
