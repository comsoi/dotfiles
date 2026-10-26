#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
KDE_DESKTOP="darkly"
KDE_WIDGET="Darkly"
QT6CT_WIDGET="Darkly"
QTENGINE_QUICK_STYLE="org.kde.desktop"

case "${1:-dark}" in
    dark)
        GTK_THEME="adw-gtk3-dark"
        GTK_ICON="WhiteSur-dark"
        GTK_USER="WhiteSur-Dark-solid"
        GTK_SCHEME="prefer-dark"

        KDE_COLOR="MaterialYouDark"
        KDE_ICON="Colloid-Catppuccin-Dark"

        QT6CT_ICON="Tela-dark"
        QT6CT_COLOR="AutogenDark"
        QT6CT_KVANTUM="KvLibadwaitaDark"

        WM_DMS="dark"
        WM_QS="setDark"
        ;;
    light)
        GTK_THEME="adw-gtk3"
        GTK_ICON="WhiteSur-light"
        GTK_USER="WhiteSur-Light-solid"
        GTK_SCHEME="prefer-light"

        KDE_COLOR="MaterialYouLight"
        KDE_ICON="Colloid-Catppuccin-Light"

        QT6CT_ICON="Tela-light"
        QT6CT_COLOR="AutogenLight"
        QT6CT_KVANTUM="KvLibadwaita"

        WM_DMS="light"
        WM_QS="setLight"
        ;;
esac

QTENGINE_ICON="$QT6CT_ICON"
QTENGINE_COLOR="$QT6CT_COLOR"
QTENGINE_WIDGET="$QT6CT_WIDGET"

# 只有真 KDE 会话才算 KDE，其余一律按 Qt/qt6ct/qtengine 处理
is_kde_session() {
	[[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* || "${XDG_CURRENT_DESKTOP:-}" == *Plasma* ]] \
		|| systemctl --user --quiet is-active plasma-workspace.target 2>/dev/null
}

# KDE 与非 KDE 使用不同的主题族；明暗两套一次都写入，由 fcitx5 自己选择。
if is_kde_session; then
	FCITX_THEME_LIGHT="materialyou-light"
	FCITX_THEME_DARK="materialyou-dark"
else
	FCITX_THEME_LIGHT="autogen-light"
	FCITX_THEME_DARK="autogen-dark"
fi

# 测试/调试用：DARKMAN_VARS_ONLY=1 时只加载上面的变量和函数，不执行任何切换动作
if [[ "${DARKMAN_VARS_ONLY:-0}" = 1 ]]; then
	return 0 2>/dev/null || exit 0
fi

if ! systemctl --user --quiet is-active org.gnome.SettingsDaemon.Color.service || [[ "$XDG_CURRENT_DESKTOP" != "GNOME" ]]; then
	if gsettings set org.gnome.desktop.interface color-scheme "$GTK_SCHEME" 2>/dev/null; then
		echo "GTK 配色方案已同步：$GTK_SCHEME"
	else
		echo "GTK 配色方案 '$GTK_SCHEME' 设置失败，跳过"
	fi
fi

source "$SCRIPT_DIR/99-gtk-theme.sh"
source "$SCRIPT_DIR/99-kde.sh"
source "$SCRIPT_DIR/99-qt6ct.sh"
source "$SCRIPT_DIR/99-qtengine.sh"
source "$SCRIPT_DIR/99-wm.sh"
source "$SCRIPT_DIR/99-fcitx5.sh"
