#!/usr/bin/env bash

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
NEW_COLOR_SCHEME_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes/Layan.colors"
sed -i "s|^color_scheme_path=.*|color_scheme_path=${NEW_COLOR_SCHEME_PATH}|" "$CONFIG_FILE"
