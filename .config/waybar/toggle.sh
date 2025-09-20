#!/bin/bash

kill -SIGUSR1 $(pidof waybar)

# XEMBED support
if systemctl --user is-active --quiet plasma-xembedsniproxy.service; then
	systemctl --user stop plasma-xembedsniproxy.service
else
	systemctl --user start plasma-xembedsniproxy.service
fi
