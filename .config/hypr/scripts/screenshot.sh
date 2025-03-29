#!/bin/bash
#  ____                               _           _
# / ___|  ___ _ __ ___  ___ _ __  ___| |__   ___ | |_
# \___ \ / __| '__/ _ \/ _ \ '_ \/ __| '_ \ / _ \| __|
#  ___) | (__| | |  __/  __/ | | \__ \ | | | (_) | |_
# |____/ \___|_|  \___|\___|_| |_|___/_| |_|\___/ \__|
#
# Based on https://github.com/hyprwm/contrib/blob/main/grimblast/screenshot.sh
# -----------------------------------------------------

# Screenshots will be stored in $HOME by default.
# The screenshot will be moved into the screenshot directory

# Add this to ~/.config/user-dirs.dirs to save screenshots in a custom folder:
# XDG_SCREENSHOTS_DIR="$HOME/Screenshots"

prompt='Screenshot'
mesg="DIR: ~/Screenshots"

# Screenshot Filename
NAME="screenshot_$(date +%Y%m%d_%H%M%S).jpg"
# Screenshot Folder
SCREENSHOT_FOLDER="$(xdg-user-dir PICTURES)/Screenshots"

# Screenshot Editor
export GRIMBLAST_EDITOR="pinta"

# Example for keybindings
# bind = SUPER, p, exec, grimblast save active
# bind = SUPER SHIFT, p, exec, grimblast save area
# bind = SUPER ALT, p, exec, grimblast save output
# bind = SUPER CTRL, p, exec, grimblast save screen

# Options
option_capture_1="Capture Selection"
option_capture_2="Capture Active Display"
option_capture_3="Capture Output"

copy='Copy'
save='Save'
copy_save='Copy & Save'
edit='Edit'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 2 -width 30 -p "Take screenshot"
}

####
# Chose Screenshot Type
# CMD
type_screenshot_cmd() {
	rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 3 -width 30 -p "Type of screenshot"
}

# Ask for confirmation
type_screenshot_exit() {
	echo -e "$option_capture_1\n$option_capture_2\n$option_capture_3" | type_screenshot_cmd
}

# Confirm and execute
type_screenshot_run() {
	selected_type_screenshot="$(type_screenshot_exit)"
	if [[ "$selected_type_screenshot" == "$option_capture_1" ]]; then
		option_type_screenshot=area
		${1}
	elif [[ "$selected_type_screenshot" == "$option_capture_2" ]]; then
		option_type_screenshot=output
		${1}
	elif [[ "$selected_type_screenshot" == "$option_capture_3" ]]; then
		option_type_screenshot=screen
		${1}
	else
		exit
	fi
}
###

####
# Choose to save or copy photo
# CMD
copy_save_editor_cmd() {
	rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 4 -width 30 -p "How to save"
}

# Ask for confirmation
copy_save_editor_exit() {
	echo -e "$copy\n$save\n$copy_save\n$edit" | copy_save_editor_cmd
}

# Confirm and execute
copy_save_editor_run() {
	selected_chosen="$(copy_save_editor_exit)"
	if [[ "$selected_chosen" == "$copy" ]]; then
		option_chosen=copy
		${1}
	elif [[ "$selected_chosen" == "$save" ]]; then
		option_chosen=save
		${1}
	elif [[ "$selected_chosen" == "$copy_save" ]]; then
		option_chosen=copysave
		${1}
	elif [[ "$selected_chosen" == "$edit" ]]; then
		option_chosen=edit
		${1}
	else
		exit
	fi
}
###

# take shots
takescreenshot() {
	sleep 0.8
	grimblast --freeze --notify "$option_chosen" "$option_type_screenshot" $NAME
	if [ -f $HOME/$NAME ]; then
		if [ -d $SCREENSHOT_FOLDER ]; then
			mv $HOME/$NAME $SCREENSHOT_FOLDER/
		fi
	fi
}

# Execute Command
run_cmd() {
	type_screenshot_run
	copy_save_editor_run "takescreenshot"
}

run_cmd
