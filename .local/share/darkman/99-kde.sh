if systemctl --user --quiet is-active plasma-workspace.target || [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]]; then
	plasma-apply-desktoptheme --platform wayland "$KDE_DESKTOP" || plasma-apply-desktoptheme --platform minimal "$KDE_DESKTOP"
	plasma-apply-colorscheme --platform offscreen "$KDE_COLOR"
	kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle --type string "$KDE_WIDGET"
	/usr/lib/plasma-changeicons --platform offscreen "$KDE_ICON"
else
	kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false
fi
