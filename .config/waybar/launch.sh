#!/bin/bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#
# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------
killall waybar
pkill waybar
sleep 0.5

# -----------------------------------------------------
# Default theme: /THEMEFOLDER;/VARIATION
# -----------------------------------------------------
themestyle="/modern;/modern/light"

if [ -f ~/.local/state/hyprland/waybar-theme ]; then
	themestyle=$(cat ~/.local/state/hyprland/waybar-theme)
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

config_file="config"
style_file="style.css"

# Check if waybar-disabled file exists
if [ ! -f $HOME/.local/state/hyprland/waybar-disabled ]; then
	uwsm app -- waybar -c ~/.config/waybar/themes${arrThemes[0]}/$config_file -s ~/.config/waybar/themes${arrThemes[1]}/$style_file &
else
	echo ":: Waybar disabled"
fi
