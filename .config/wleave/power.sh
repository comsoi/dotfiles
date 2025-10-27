#!/bin/bash

if [[ "$1" == "exit" ]]; then
	echo ":: Exit"
	sleep 0.5
	if [[ $NIRI_SOCKET ]]; then
		niri msg action quit
		exit
	fi
	uwsm stop
	exit
fi


