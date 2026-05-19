#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
KDE_DESKTOP="darkly"
KDE_WIDGET="Darkly"
QT6CT_WIDGET="Darkly"

case "${1:-dark}" in
    dark)
        GTK_THEME="adw-gtk3-dark"
        GTK_ICON="WhiteSur-dark"
        GTK_USER="WhiteSur-Dark-solid"
        GTK_SCHEME="prefer-dark"

        KDE_COLOR="MaterialYouDark"
        KDE_ICON="Colloid-Catppuccin-Dark"

        QT6CT_ICON="Tela-dark"
        QT6CT_COLOR="MatugenDark"
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
        QT6CT_COLOR="MatugenLight"
        QT6CT_KVANTUM="KvLibadwaita"

        WM_DMS="light"
        WM_QS="setLight"
        ;;
esac

if ! systemctl --user --quiet is-active org.gnome.SettingsDaemon.Color.service || [[ "$XDG_CURRENT_DESKTOP" != "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface color-scheme "$GTK_SCHEME"
fi

source "$SCRIPT_DIR/99-gtk-theme.sh"
source "$SCRIPT_DIR/99-kde.sh"
source "$SCRIPT_DIR/99-qt6ct.sh"
source "$SCRIPT_DIR/99-wm.sh"
