#!/bin/bash

SERVICE="hypridle"

print_status() {
	if systemctl --user is-active --quiet hypridle.service; then
		echo '{"text": "RUNNING", "class": "active", "tooltip": "Screen locking active\nLeft: Toggle idle\nRight: Lock Screen"}'
	else
		echo '{"text": "NOT RUNNING", "class": "notactive", "tooltip": "Screen locking deactivated\nLeft: Toggle idle\nRight: Lock Screen"}'
	fi
}

case "$1" in
status)
	print_status
	;;
toggle)
	if systemctl --user is-active --quiet hypridle.service; then
		systemctl --user stop hypridle.service
	else
		systemctl --user start hypridle.service
	fi
	print_status
	;;
*)
	echo "Usage: $0 {status|toggle}"
	exit 1
	;;
esac
