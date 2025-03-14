#!/bin/bash

if [ -f $HOME/.local/state/hyprland/waybar-disabled ]; then
	rm $HOME/.local/state/hyprland/waybar-disabled
else
	touch $HOME/.local/state/hyprland/waybar-disabled
fi
$HOME/.config/waybar/launch.sh &
