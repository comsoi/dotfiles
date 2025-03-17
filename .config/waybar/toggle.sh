#!/bin/bash

if [ -f $HOME/.local/state/hyprland/waybar-disabled ]; then
	rm $HOME/.local/state/hyprland/waybar-disabled
	uwsm app -- /usr/bin/xembedsniproxy
else
	touch $HOME/.local/state/hyprland/waybar-disabled
	pkill xembedsniproxy
fi
$HOME/.config/waybar/launch.sh &
