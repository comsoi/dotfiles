#!/bin/bash

if [[ $HYPRLAND_INSTANCE_SIGNATURE == "" ]]; then
	exec wlogout
	exit 0
fi

res_w=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
res_h=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
h_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')
w_margin=$((res_h * 27 / h_scale))
exec wlogout -b 3 -T $w_margin -B $w_margin
