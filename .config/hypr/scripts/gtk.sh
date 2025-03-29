#!/usr/bin/env bash

config_gtk3="$HOME/.config/gtk-3.0/settings.ini"
gtk4_dir="$HOME/.config/gtk-4.0"
config_gtk4="$gtk4_dir/settings.ini"
gnome_schema="org.gnome.desktop.interface"
theme_locations=(
	"$HOME/.local/share/themes"
	"$HOME/.themes"
	"/usr/share/themes"
	"/usr/local/share/themes"
)

[[ -f "$config_gtk3" ]] || {
	mkdir -p "$(dirname "$config_gtk3")"
	touch "$config_gtk3"
}
[[ -d "$gtk4_dir" ]] || {
	mkdir -p "$gtk4_dir"
	touch "$config_gtk4"
}

read_setting() {
	gsettings get "$gnome_schema" "$1" | tr -d "'"
}

create_symlink() {
	local src="$1"
	local dest="$2"

	if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
		echo "Symlink already exists: $dest -> $src"
	else
		rm -f "$dest"
		ln -sf "$src" "$dest"
		echo "Created symlink: $dest -> $src"
	fi
}

# Get all settings at once
gtk_theme=$(read_setting gtk-theme)
icon_theme=$(read_setting icon-theme)
cursor_theme=$(read_setting cursor-theme)
cursor_size=$(read_setting cursor-size)
font_name=$(read_setting font-name)
font_antialiasing=$(read_setting font-antialiasing)
font_rgba_order=$(read_setting font-rgba-order)
font_hintstyle=$(read_setting font-hinting)
prefer_dark_theme=$(read_setting color-scheme)

# Process settings
prefer_dark_theme_value=$([[ "$prefer_dark_theme" == "prefer-dark" ]] && echo "1" || echo "0")
font_antialiasing=$([[ "$font_antialiasing" != "none" ]] && echo "1" || echo "0")

theme_path=""
for location in "${theme_locations[@]}"; do
	if [ -d "$location/$gtk_theme/gtk-4.0" ]; then
		theme_path="$location/$gtk_theme/gtk-4.0"
		break
	fi
done

# Handle font hinting
if [[ "$font_hintstyle" != "none" ]]; then
	font_hinting="1"
	case "$font_hintstyle" in
	slight) font_hintstyle="hintslight" ;;
	medium) font_hintstyle="hintmedium" ;;
	full) font_hintstyle="hintfull" ;;
	*) font_hintstyle="hintnone" ;;
	esac
else
	font_hinting="0"
	font_hintstyle="hintnone"
fi

# Debug output
echo "Applying GTK settings:"
echo "  Theme: $gtk_theme (Dark mode: $prefer_dark_theme_value)"
echo "  Icons: $icon_theme, Cursor: $cursor_theme ($cursor_size)"
echo "  Font: $font_name ($font_hinting)($font_hintstyle)($font_antialiasing)($font_rgba_order)"

# Apply settings
crudini --set "$config_gtk3" Settings gtk-theme-name "$gtk_theme"
crudini --set "$config_gtk3" Settings gtk-icon-theme-name "$icon_theme"
crudini --set "$config_gtk3" Settings gtk-cursor-theme-name "$cursor_theme"
crudini --set "$config_gtk3" Settings gtk-cursor-theme-size "$cursor_size"
crudini --set "$config_gtk3" Settings gtk-font-name "$font_name"
crudini --set "$config_gtk3" Settings gtk-xft-rgba "$font_rgba_order"
crudini --set "$config_gtk3" Settings gtk-xft-antialias "$font_antialiasing"
crudini --set "$config_gtk3" Settings gtk-xft-hinting "$font_hinting"
crudini --set "$config_gtk3" Settings gtk-xft-hintstyle "$font_hintstyle"
crudini --set "$config_gtk3" Settings gtk-application-prefer-dark-theme "$prefer_dark_theme_value"
crudini --set "$config_gtk4" Settings gtk-application-prefer-dark-theme "$prefer_dark_theme_value"

if [ -z "$theme_path" ]; then
	echo "Error: Theme directory not found for $gtk_theme"
	exit 1
fi

# [ -f "$theme_path"/gtk.css ] && create_symlink "$theme_path/gtk.css" "$gtk4_dir/gtk.css"
# [ -f "$theme_path/gtk-dark.css" ] && create_symlink "$theme_path/gtk-dark.css" "$gtk4_dir/gtk-dark.css"
# [ -d "$theme_path/assets" ] && create_symlink "$theme_path/assets" "$gtk4_dir/assets"

# if [[ -f ~/.config/hypr/conf/cursor.conf ]]; then
# 	sed -i "s|^exec-once = hyprctl setcursor.*|exec-once = hyprctl setcursor $cursor_theme $cursor_size|" ~/.config/hypr/conf/cursor.conf
# 	hyprctl setcursor "$cursor_theme" "$cursor_size"
# fi
