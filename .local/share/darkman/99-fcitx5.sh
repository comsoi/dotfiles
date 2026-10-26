#!/usr/bin/env bash
# fcitx5 明暗两套主题一次写入，由 UseDarkTheme 自行选择。
# KDE 使用 materialyou-*，其它桌面使用 autogen-*。

fcitx_light="${FCITX_THEME_LIGHT:-}"
fcitx_dark="${FCITX_THEME_DARK:-}"

if [[ -z "$fcitx_light" || -z "$fcitx_dark" ]]; then
	echo "未设置 fcitx5 主题，跳过同步"
	return 0 2>/dev/null || exit 0
fi

fcitx_conf="${XDG_CONFIG_HOME:-$HOME/.config}/fcitx5/conf/classicui.conf"
if [[ ! -f "$fcitx_conf" ]]; then
	echo "未找到 fcitx5 classicui.conf，跳过主题同步"
	return 0 2>/dev/null || exit 0
fi

set_fcitx_value() {
	local key="$1"
	local value="$2"
	if grep -q "^$key=" "$fcitx_conf"; then
		sed -i "s|^$key=.*|$key=$value|" "$fcitx_conf"
	else
		printf '%s=%s\n' "$key" "$value" >>"$fcitx_conf"
	fi
}

set_fcitx_value Theme "$fcitx_light"
set_fcitx_value DarkTheme "$fcitx_dark"
set_fcitx_value UseDarkTheme True

if fcitx5-remote --check >/dev/null 2>&1; then
	dbus-send --session --print-reply \
		--dest=org.fcitx.Fcitx5 \
		/controller org.fcitx.Fcitx.Controller1.ReloadAddonConfig \
		string:classicui >/dev/null 2>&1 || true
fi

echo "fcitx5 已同步主题：$fcitx_light / $fcitx_dark"
