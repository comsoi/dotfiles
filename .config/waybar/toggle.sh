#!/bin/bash

if systemctl --user is-active --quiet waybar.service; then
	pkill xembedsniproxy
	# systemctl --user stop waybar.service
	kill -SIGUSR1 $(pidof waybar)
else
	# systemctl --user start waybar.service
	kill -SIGUSR1 $(pidof waybar)
	exec uwsm app -- /usr/bin/xembedsniproxy
fi
