#!/usr/bin/env bash
# KDE 会话 → KDE 这一套说了算（配色/图标/桌面主题/控件样式）
# 非 KDE 会话 → 不碰任何 KDE 配置，交给 99-qt6ct.sh

if is_kde_session; then
	kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false

	plasma-apply-desktoptheme --platform wayland "$KDE_DESKTOP" \
		|| plasma-apply-desktoptheme --platform minimal "$KDE_DESKTOP" \
		|| echo "plasma-apply-desktoptheme '$KDE_DESKTOP' 失败，跳过"

	plasma-apply-colorscheme --platform offscreen "$KDE_COLOR" \
		|| echo "plasma-apply-colorscheme '$KDE_COLOR' 失败，跳过"

	kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle --type string "$KDE_WIDGET"

	if [ -x /usr/lib/plasma-changeicons ]; then
		/usr/lib/plasma-changeicons --platform offscreen "$KDE_ICON" \
			|| echo "plasma-changeicons '$KDE_ICON' 失败，跳过"
	fi

	echo "KDE 会话：已应用 KDE 配色 '$KDE_COLOR'、图标 '$KDE_ICON'、控件样式 '$KDE_WIDGET'"
else
	echo "非 KDE 会话：跳过 KDE 配置"
fi
