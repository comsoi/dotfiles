#!/usr/bin/env bash
# qt6ct 的配置在两种会话里都同步（KDE 会话里也可能有程序用 qt6ct）
# 非 KDE 会话 → qt6ct 是主角，同时把同一套配色/图标/样式镜像进 kdeglobals，
#               免得 KDE 系组件（dolphin、KFileWidget 文件对话框、portal 后端）和 qt6ct 脱节

qt_config="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
kde_globals="${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals"

color_path=""
for dir in "${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes" "/usr/share/color-schemes"; do
	[[ -f "$dir/$QT6CT_COLOR.colors" ]] && { color_path="$dir/$QT6CT_COLOR.colors"; break; }
done

_qt6ct() {
	[[ -f "$qt_config" ]] || return 0
	sed -i "s|^$1=.*|$1=$2|" "$qt_config"
}

# ── qt6ct.conf：两种会话都同步 ─────────────────────────────
if [[ -n "$color_path" ]]; then
	_qt6ct color_scheme_path "$color_path"
else
	echo "找不到 '$QT6CT_COLOR.colors'，qt6ct 的 color_scheme_path 保持原样"
fi
_qt6ct icon_theme "$QT6CT_ICON"
_qt6ct style "$QT6CT_WIDGET"
echo "qt6ct 已同步：配色 '$QT6CT_COLOR'、图标 '$QT6CT_ICON'、样式 '$QT6CT_WIDGET'"

if command -v kvantummanager >/dev/null; then
	# kvantummanager 是 Qt GUI 程序，偶尔会卡住；加超时避免拖死整个 darkman 切换
	timeout 20 kvantummanager --set "$QT6CT_KVANTUM" >/dev/null 2>&1 \
		|| echo "kvantummanager --set '$QT6CT_KVANTUM' 失败或超时，跳过"
fi

# ── kdeglobals 镜像：只在非 KDE 会话做 ─────────────────────
if is_kde_session; then
	echo "KDE 会话：kdeglobals 由 99-kde.sh 负责，这里不动"
else
	if [[ -n "$color_path" ]]; then
		plasma-apply-colorscheme --platform offscreen "$QT6CT_COLOR" \
			|| echo "plasma-apply-colorscheme '$QT6CT_COLOR' 失败，[Colors:*] 未同步"
	fi
	kwriteconfig6 --file "$kde_globals" --group General --key ColorScheme "$QT6CT_COLOR"
	kwriteconfig6 --file "$kde_globals" --group Icons --key Theme "$QT6CT_ICON"
	kwriteconfig6 --file "$kde_globals" --group KDE --key widgetStyle --type string "$QT6CT_WIDGET"
	# 旧的 LookAndFeelPackage（例如 org.kde.breezedark.desktop）会在部分 KDE 组件里把配色盖回去，
	# 非 KDE 会话下直接清掉，让它们只认我们同步过去的 [Colors:*]
	kwriteconfig6 --file "$kde_globals" --group KDE --key LookAndFeelPackage --delete
	echo "非 KDE 会话：已把 qt6ct 的配色/图标/样式镜像进 kdeglobals（并清掉旧的 LookAndFeelPackage）"
fi
