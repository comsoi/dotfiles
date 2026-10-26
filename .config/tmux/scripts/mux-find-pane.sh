#!/bin/sh
# mux-find-pane.sh —— 跨 pane 模糊搜索并跳转，tmux / zellij / wezterm 共用。
#   实体存放在 dotfiles（~/.config/dotfiles/.config/tmux/scripts/mux-find-pane.sh），不进 PATH；
#   tmux / zellij 配置统一用 sh $HOME/... 调用（tmux 加载配置时展开、zellij 借 sh 运行时展开，
#   文件里都不含用户名）。
#   tmux   ：conf/keys/window.tmux 的 `bind f` 用 display-popup 跑本脚本
#   zellij ：config.kdl 的 tmux 模式 `bind f` 用 Run（浮动 pane）跑本脚本，选完自毁
#   wezterm：**不再挂键**（Leader+f 走 ~/.config/wezterm/utils/find_pane.lua 的 Lua 版，
#           候选/预览都用 Lua API 收集）；wezterm 分支保留下来方便手工调用/对照
# 搜索范围：每个 pane 的可见内容 + 最近 MUX_FIND_LINES 行历史（默认 2000）
# 依赖：fzf；wezterm 侧另需 wezterm cli + jq，zellij 侧另需 zellij cli + jq
#
# 预览定位（与 wezterm 的 Lua 版对齐）：每个 pane 的原文先落盘到临时目录，候选里带**物理行号**，
# 预览直接读同一份文件，并用 fzf 的 `+{3}/2` 把选中行滚到预览区正中间。
#   - 行号按完整文本计数（含装饰行/空行），装饰行和空行本身不进候选（见 grep -nvP + awk 过滤）
#   - 不能让 fzf 的占位符参与 shell 算术：它替换出来是**带单引号的字符串**（$(( '40' + 20 )) 会报错）
#   - `--ellipsis=''`：fzf 默认截断标记是 `··`（手册 --ellipsis 默认值），长行末尾会冒出两个点

set -u

LINES=${MUX_FIND_LINES:-2000}
export LINES
TAB=$(printf '\t')

# 颜色：默认保留 pane 内容里的 ANSI 样式，fzf 用 --ansi 解析（匹配时忽略颜色码）。
# 带色后每行体积更大，若觉得卡顿可以 MUX_FIND_COLOR=0 关掉。
if [ "${MUX_FIND_COLOR:-1}" = "0" ]; then
	FZF_ANSI=""
	WEZ_COLOR=""
	TMUX_COLOR=""
	ZELLIJ_COLOR=""
else
	FZF_ANSI="--ansi"
	WEZ_COLOR="--escapes"
	TMUX_COLOR="-e"
	ZELLIJ_COLOR="--ansi"
fi

case "${1:-}" in
wezterm | tmux | zellij) MODE=$1 ;;
*)
	if [ -n "${ZELLIJ:-}" ]; then
		MODE=zellij
	elif [ -n "${WEZTERM_PANE:-}" ]; then
		MODE=wezterm
	elif [ -n "${TMUX:-}" ]; then
		MODE=tmux
	else
		echo "不在 wezterm / tmux / zellij 里" >&2
		exit 1
	fi
	;;
esac

# 装饰行：私有使用区（powerline 箭头 / nerd font 图标）、box drawing、块元素。
# 这些行不进候选，但**仍然算行号**（grep -n 给的是完整文本里的物理行号）。
CHROME_RE='[\x{E000}-\x{F8FF}\x{2500}-\x{259F}]'

# 每个 pane 的原文（含装饰行、含颜色）落盘，预览和候选行号都用这一份
FIND_TMP=$(mktemp -d "${TMPDIR:-/tmp}/mux-find.XXXXXX")
trap 'rm -rf "$FIND_TMP"' EXIT INT TERM
# 万一某次运行被强杀（trap 没跑到）会留下临时目录：顺手清掉 1 小时前的同名残留，
# 只按名字+时间筛，正在跑的那份（刚建）不会被误删。
find "${TMPDIR:-/tmp}" -maxdepth 1 -type d -name 'mux-find.*' -mmin +60 -exec rm -rf {} + 2>/dev/null || true

# 收集一个 pane：emit_pane <pane id> <显示前缀> <取文本命令...>
# 行格式（三个分支统一）："<显示文本> \t <pane id> \t <行号>"
#   - 显示文本内部只用空格：fzf 会把行内 TAB 渲染成 "··"（每个字段边界都会冒出来），
#     所以 TAB 只做字段分隔，显示和搜索都只用第 1 列（--nth=1 --with-nth=1）
#   - 预览的 {2} 就是这里的 pane id，{3} 是行号（fzf 的 field 占位符基于原始行）
emit_pane() {
	_id=$1
	_prefix=$2
	shift 2
	_file="$FIND_TMP/$_id.txt"
	# tr -d '\r'：wezterm cli get-text 用 \r\n 结尾，留着的 \r 会被 fzf 渲染成 "·"（列表里那串 "··" 就是它）
	if ! "$@" 2>/dev/null | tr -d '\r' >"$_file"; then
		: >"$_file"
	fi
	grep -nvP "$CHROME_RE" "$_file" 2>/dev/null | grep -v ':$' |
		awk -v id="$_id" -v prefix="$_prefix" -v tabc="$TAB" '
			{
				no = $0; sub(/:.*/, "", no)
				line = $0; sub(/^[0-9]+:/, "", line)
				gsub(/\t/, " ", line)
				if (line ~ /[^ \t]/) { p++; printf "%s %s%s%s%s%s\n", prefix, line, tabc, id, tabc, no }
			}
			END { if (p == 0) printf "%s%s%s%s%d\n", prefix, tabc, id, tabc, 1 }'
}

if [ "$MODE" = "wezterm" ]; then
	json=$(wezterm cli list --format json 2>/dev/null) || {
		echo "wezterm cli list 失败（拿不到 mux 连接）"
		[ -n "${WEZTERM_PANE:-}" ] && sleep 3 && wezterm cli kill-pane --pane-id "$WEZTERM_PANE" 2>/dev/null
		exit 1
	}
	# 排除脚本自己所在的那个 pane（Leader+f 会先把 fzf 临时 pane 建出来，再跑本脚本）
	panes=$(printf '%s' "$json" | jq -r --arg self "${WEZTERM_PANE:-}" '
		.[] | select((.pane_id | tostring) != $self)
		    | [(.pane_id | tostring), (.tab_id | tostring), (.title // .pane_title // "")] | @tsv' 2>/dev/null)
	if [ -z "$panes" ]; then
		echo "解析 wezterm cli list 的 JSON 失败，原始内容前几行："
		printf '%s\n' "$json" | head -5
		[ -n "${WEZTERM_PANE:-}" ] && sleep 5 && wezterm cli kill-pane --pane-id "$WEZTERM_PANE" 2>/dev/null
		exit 1
	fi

	printf '%s\n' "$panes" | while IFS="$TAB" read -r id tab title; do
		[ -n "${id:-}" ] || continue
		emit_pane "$id" "$tab $title" \
			wezterm cli get-text --pane-id "$id" --start-line "-$LINES" $WEZ_COLOR
	done |
		fzf --delimiter="$TAB" --nth=1 --with-nth=1 --ellipsis='' --no-hscroll $FZF_ANSI \
			--header='回车跳转 · 输入即搜（含最近历史 · 预览定位选中行）' \
			--preview "cat $FIND_TMP/{2}.txt" \
			"--preview-window=right:55%,+{3}/2" |
		head -n1 | cut -f2 | while read -r id; do
			[ -n "${id:-}" ] || continue
			wezterm cli activate-pane --pane-id "$id" 2>/dev/null || true
		done

	# 关掉这个临时 pane
	if [ -n "${WEZTERM_PANE:-}" ]; then
		wezterm cli kill-pane --pane-id "$WEZTERM_PANE" 2>/dev/null || true
	fi
	exit 0
fi

# tmux 分支
if [ "$MODE" = "tmux" ]; then
	tmux list-panes -aF "#{pane_id}${TAB}#{session_name}:#{window_index}.#{pane_index}${TAB}#{pane_title}${TAB}#{pane_current_command}" |
		while IFS="$TAB" read -r id loc title cmd; do
			[ -n "${id:-}" ] || continue
			emit_pane "$id" "$loc $title $cmd" \
				tmux capture-pane -p $TMUX_COLOR -S "-$LINES" -t "$id"
		done |
		fzf --delimiter="$TAB" --nth=1 --with-nth=1 --ellipsis='' --no-hscroll $FZF_ANSI \
			--header='回车跳转 · 输入即搜（含最近历史 · 预览定位选中行）' \
			--preview "cat $FIND_TMP/{2}.txt" \
			"--preview-window=right:55%,+{3}/2" |
		head -n1 | cut -f2 | while read -r id; do
			[ -n "${id:-}" ] || continue
			tmux select-window -t "$id" 2>/dev/null || true
			tmux select-pane -t "$id" 2>/dev/null || true
		done
	exit 0
fi

# zellij 分支（自己所在的临时 pane 用 ZELLIJ_PANE_ID 排除，最后再关掉）
if [ "$MODE" = "zellij" ]; then
	zellij action list-panes -a -j 2>/dev/null |
		jq -r --arg self "${ZELLIJ_PANE_ID:-}" '
			.[] | select(.is_plugin != true)
			    | select((.id | tostring) != $self)
			    | [(.id | tostring), (.tab_position | tostring),
			       (.tab_name // ""), (.pane_command // .title // "")] | @tsv' 2>/dev/null |
		while IFS="$TAB" read -r id tabpos tabname cmd; do
			[ -n "${id:-}" ] || continue
			emit_pane "$id" "$tabpos $tabname $cmd" \
				sh -c "zellij action dump-screen --pane-id '$id' -f $ZELLIJ_COLOR | tail -n $LINES"
		done |
		fzf --delimiter="$TAB" --nth=1 --with-nth=1 --ellipsis='' --no-hscroll $FZF_ANSI \
			--header='回车跳转 · 输入即搜（含最近历史 · 预览定位选中行）' \
			--preview "cat $FIND_TMP/{2}.txt" \
			"--preview-window=right:55%,+{3}/2" |
		head -n1 | cut -f2 | while read -r id; do
			[ -n "${id:-}" ] || continue
			# 关掉浮动 pane 会把 client 焦点「移回」它覆盖的 tiled pane
			# （zellij-server close_pane 里的 floating_panes.move_clients_out_of_pane），
			# 所以跳转只能排在关窗之后 —— 交给脱离 pty 会话的后台进程延迟补一次。
			setsid -f sh -c "sleep 0.3; zellij action focus-pane-id $id" </dev/null >/dev/null 2>&1 ||
				zellij action focus-pane-id "$id" 2>/dev/null || true
		done

	# 关掉这个临时 pane
	if [ -n "${ZELLIJ_PANE_ID:-}" ]; then
		zellij action close-pane --pane-id "$ZELLIJ_PANE_ID" 2>/dev/null || true
	fi
fi
