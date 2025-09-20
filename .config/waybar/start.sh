#!/bin/bash

# Define default themes
themestyle_default="/modern;/modern/light"
themestyle="$themestyle_default"

# Check for theme override file
# Use $HOME for reliability in systemd user units
theme_override_file="$HOME/.local/state/waybar/waybar-theme"
if [ -f "$theme_override_file" ]; then
	themestyle=$(cat "$theme_override_file")
fi

# Split theme string into config and style paths
# IFS=';' read -ra arrThemes <<<"$themestyle" # Original, might be okay, but manual split is sometimes more robust
# Let's use parameter expansion for robustness in case IFS is messed with
# Read config path up to first ';', rest is style path
config_theme="${themestyle%%;*}"
style_theme="${themestyle#*;}"

# If splitting failed or only one part, fall back to default
if [[ "$config_theme" == "$themestyle" || -z "$style_theme" ]]; then
	echo ":: Warning: Invalid theme style format '$themestyle', using default '$themestyle_default'." >&2
	config_theme="${themestyle_default%%;*}"
	style_theme="${themestyle_default#*;}"
fi

echo ":: Waybar Config Theme: $config_theme"
echo ":: Waybar Style Theme: $style_theme"

config_file="config"
style_file="style.css"

# Construct full paths
config_path="$HOME/.config/waybar/themes${config_theme}/$config_file"
style_path="$HOME/.config/waybar/themes${style_theme}/$style_file"

# Check if waybar-disabled file exists
echo ":: Starting Waybar with config $config_path and style $style_path"

exec /usr/bin/waybar -c "$config_path" -s "$style_path"

exit 1
