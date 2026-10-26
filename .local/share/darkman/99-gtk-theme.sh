gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" \
	|| echo "GTK 主题 '$GTK_THEME' 设置失败，跳过"
gsettings set org.gnome.desktop.interface icon-theme "$GTK_ICON" \
	|| echo "GTK 图标 '$GTK_ICON' 设置失败，跳过"
gsettings set org.gnome.shell.extensions.user-theme name "$GTK_USER" \
	|| echo "GTK UserTheme '$GTK_USER' 设置失败（可能没装 user-theme 扩展），跳过"

echo "GTK 已同步：主题 '$GTK_THEME'、图标 '$GTK_ICON'、UserTheme '$GTK_USER'"
