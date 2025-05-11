#!/bin/bash

if systemctl --user is-active --quiet waybar.service; then
	pkill xembedsniproxy
	systemctl --user stop waybar.service
else
	systemctl --user start waybar.service
	exec uwsm app -- /usr/bin/xembedsniproxy
fi
