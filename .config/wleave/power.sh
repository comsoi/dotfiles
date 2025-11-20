#!/bin/bash

if [[ "$1" == "exit" ]]; then
	echo ":: Exit"
	sleep 0.5
	if [[ $WAYFIRE_SOCKET ]] && ! uwsm check is-active; then
		killall wayfire
		exit
	fi
	if [[ $NIRI_SOCKET ]]; then
		niri msg action quit
		exit
	fi
	if [[ $HYPRLAND_INSTANCE_SIGNATURE ]] && ! uwsm check is-active; then
		hyprctl dispatch exit
		exit
	fi
	uwsm stop
	exit
fi


