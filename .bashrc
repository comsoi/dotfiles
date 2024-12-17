#    _               _
#   | |__   __ _ ___| |__  _ __ ___
#   | '_ \ / _` / __| '_ \| '__/ __|
#  _| |_) | (_| \__ \ | | | | | (__
# (_)_.__/ \__,_|___/_| |_|_|  \___|
#
# -----------------------------------------------------
# Load modular configarion
# -----------------------------------------------------

 # If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set language environment
if [[ $(tty) == /dev/pts/* ]]; then
	export LANG=zh_CN.UTF-8
	export LANGUAGE=zh_CN:en_US:en
fi

for file in ~/.config/bash/*; do
  [[ -r "$file" ]] && . "$file"
done
