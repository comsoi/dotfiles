#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#

killall nwg-dock-hyprland
pkill nwg-dock-hyprla

config="$HOME/.config/gtk-3.0/settings.ini"
prefer_dark_theme="$(grep 'gtk-application-prefer-dark-theme' "$config" | sed 's/.*\s*=\s*//')"
if [ $prefer_dark_theme == 0 ]; then
	style="style-light.css"
else
	style="style-dark.css"
fi

uwsm app -- nwg-dock-hyprland -d -i 32 -w 5 -mb 10 -ml 10 -mr 10 -s $style -c "rofi -show drun" &
