#!/bin/bash

case $1 in
d)
	cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist delete
	;;

w)
	if [ $(echo -e "Clear\nCancel" | rofi -dmenu -config ~/.config/rofi/config-short.rasi) == "Clear" ]; then
		cliphist wipe
	fi
	;;

*)
	# cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist decode | wl-copy
	~/.config/hypr/scripts/cliphist-rofi-img.sh | rofi -dmenu -replace -display-columns 2 -config ~/.config/rofi/config-cliphist.rasi | cliphist decode | wl-copy
	;;
esac
