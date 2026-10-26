#!/usr/bin/env bash
# 将当前 darkman 配色同步到 qtengine，保留字体、misc 等其它配置。

qtengine_config="${XDG_CONFIG_HOME:-$HOME/.config}/qtengine/config.json"

if ! command -v jq >/dev/null 2>&1; then
	echo "jq 不可用，跳过 qtengine 同步"
	return 0
fi

if [[ ! -f "$qtengine_config" ]]; then
	echo "未找到 $qtengine_config，跳过 qtengine 同步"
	return 0
fi

color_path=""
for dir in "${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes" "/usr/share/color-schemes"; do
	if [[ -f "$dir/$QTENGINE_COLOR.colors" ]]; then
		color_path="$dir/$QTENGINE_COLOR.colors"
		break
	fi
done

if [[ -z "$color_path" ]]; then
	echo "找不到 '$QTENGINE_COLOR.colors'，qtengine 的 colorScheme 保持原样"
fi

tmp_config="$(mktemp "${qtengine_config}.XXXXXX")" || {
	echo "无法创建 qtengine 临时配置" >&2
	return 1
}

jq_args=(
	--arg icon_theme "$QTENGINE_ICON"
	--arg style "$QTENGINE_WIDGET"
	--arg quick_style "$QTENGINE_QUICK_STYLE"
)
jq_filter='
	.theme = (.theme // {})
	| .theme.iconTheme = $icon_theme
	| .theme.style = $style
	| .theme.quickStyle = $quick_style
'

if [[ -n "$color_path" ]]; then
	jq_args+=(--arg color_scheme "$color_path")
	jq_filter+=' | .theme.colorScheme = $color_scheme'
fi

if jq "${jq_args[@]}" "$jq_filter" "$qtengine_config" >"$tmp_config"; then
	chmod --reference="$qtengine_config" "$tmp_config" 2>/dev/null || chmod 0644 "$tmp_config"
	mv -f "$tmp_config" "$qtengine_config"
	echo "qtengine 已同步：配色 '${QTENGINE_COLOR}'、图标 '$QTENGINE_ICON'、样式 '$QTENGINE_WIDGET'"
else
	rm -f "$tmp_config"
	echo "qtengine 配置更新失败，原配置保持不变" >&2
	return 1
fi
