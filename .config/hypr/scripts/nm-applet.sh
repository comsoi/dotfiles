#!/bin/bash

if [[ "$1" == "stop" ]]; then
    killall nm-applet
elif [[ "$1" == "toggle" ]]; then
    if pgrep -x "nm-applet" >/dev/null; then
        echo "Running"
        killall nm-applet
    else
        echo "Stopped"
        exec uwsm app -- nm-applet --indicator
    fi
fi
