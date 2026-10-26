#!/bin/bash
# pick-tab.sh —— zellij 版 tab/pane 导航器（对齐 tmux 的 choose-tree）。
#   自绘 TUI：上半是「tab → pane」树 —— tab 行（名称 + pane 数，当前 tab 标 *）
#   下面缩进列出它的 pane（命令名，当前聚焦的标 ←）；下半是选中项的实时预览。
#   ↑↓ / jk 选择（tab 行和 pane 行都可选）· 回车跳转 · q 或 Esc 取消。
#   选 tab 行走 `go-to-tab-by-id`，选 pane 行走 `focus-pane-id`（会顺带切到该 tab）。
#   挂在 zellij 的 `C-s w`。
# 依赖：jq；本文件在 ~/.config/zellij/scripts/，由 ~/.config/zellij/config.kdl 的 tmux 模式
# `bind "w"` 用 Run 拉起（浮动 pane）。

set -u
TAB=$(printf '\t')
MUX_FIND_LINES=${MUX_FIND_LINES:-2000}

# 配色（256 色）
C_RST=$'\033[0m'
C_TAB=$'\033[1;38;5;110m'  # tab 行
C_PANE=$'\033[38;5;250m'   # pane 行
C_SEL=$'\033[1;38;5;231;48;5;238m'   # 选中行：加粗白字 + 深灰底
C_ACT=$'\033[38;5;114m'    # 当前 tab / 当前 pane 标记
C_DIM=$'\033[38;5;60m'     # 分隔线
C_KEY=$'\033[1;38;5;222m'  # 提示里的按键
C_HINT=$'\033[38;5;110m'   # 提示文字

# 按「可见宽度」截断（保留 ANSI 颜色序列），$1 = 最大宽度
ansi_cut() {
	PERL_MAX="$1" perl -CS -pe '
		my $max = $ENV{PERL_MAX};
		my ($out, $w) = ("", 0);
		while (length) {
			if (s/^\x1b\[[0-9;?]*[A-Za-z]//) { $out .= $&; next }
			last if $w >= $max;
			s/^(.)// or last;
			$out .= $1; $w++;
		}
		$_ = $out . "\x1b[0m\n";
	'
}

close_self() {
	printf '%s' "$C_RST"
	printf '\033[?25h'
	[ -n "${ZELLIJ_PANE_ID:-}" ] && zellij action close-pane --pane-id "$ZELLIJ_PANE_ID" 2>/dev/null
}

snapshot() {
	panes=$(zellij action list-panes -a -j 2>/dev/null)
	tabs=$(zellij action list-tabs -j 2>/dev/null)
}

# 某个 tab 里用来做预览的 pane（优先聚焦的，否则第一个）
# 必须排除浮动 pane（浮窗自己 is_focused=true，否则预览会显示浮窗自己）
preview_pane_of_tab() {
	printf '%s' "$panes" | jq -r --argjson tp "$1" --arg self "${ZELLIJ_PANE_ID:-}" '
		[.[] | select(.is_plugin != true) | select(.is_floating != true)
		    | select((.id | tostring) != $self) | select(.tab_position == $tp)]
		| ((map(select(.is_focused)) | first) // first) | .id' 2>/dev/null | head -n1
}

# 构建树：items 里每项是 "kind|target|preview_pane|文本|标记"
#   kind=tab  → target 是 tab_id，跳转用 go-to-tab-by-id
#   kind=pane → target 是 pane id，跳转用 focus-pane-id
build_items() {
	items=()
	tab_indexes=()
	local tid tname tpos tact cnt pid pcmd pfoc pmark tno=0 pno
	while IFS="$TAB" read -r tid tname tpos tact; do
		[ -n "${tid:-}" ] || continue
		tno=$((tno + 1))
		tab_indexes+=("${#items[@]}")     # 记录 tab 行在 items 里的下标（Tab 键用它跳）
		cnt=$(printf '%s' "$panes" | jq -r --argjson tp "$tpos" --arg self "${ZELLIJ_PANE_ID:-}" '
			[.[] | select(.is_plugin != true) | select(.is_floating != true)
			    | select((.id | tostring) != $self) | select(.tab_position == $tp)] | length' 2>/dev/null)
		pmark=""
		[ "$tact" = "true" ] && pmark="*"
		items+=("tab|$tid|$(preview_pane_of_tab "$tpos")|$(printf '%2d) %s  %s pane' "$tno" "$tname" "$cnt")|$pmark")
		# 只有一个 pane 的 tab 不再列出子行：选 tab 本身就等于跳到那个 pane，列出来只是噪音
		[ "${cnt:-0}" -gt 1 ] || continue
		pno=0
		while IFS="$TAB" read -r pid pcmd ptp pfoc; do
			[ -n "${pid:-}" ] || continue
			pno=$((pno + 1))
			if [ "$pfoc" = "true" ] && [ "$tact" = "true" ]; then pmark="←"; else pmark=""; fi
			items+=("pane|$pid|$pid|$(printf '     %d.%d  %s' "$tno" "$pno" "$pcmd")|$pmark")
		done < <(printf '%s' "$panes" | jq -r --argjson tp "$tpos" --arg self "${ZELLIJ_PANE_ID:-}" '
			.[] | select(.is_plugin != true) | select(.is_floating != true)
			| select((.id | tostring) != $self) | select(.tab_position == $tp)
			| [(.id | tostring), (.pane_command // .title // "?"), (.tab_position | tostring), (.is_focused | tostring)] | @tsv' 2>/dev/null)
	done < <(printf '%s' "$tabs" | jq -r '.[] | [(.tab_id | tostring), .name, (.position | tostring), (.active | tostring)] | @tsv' 2>/dev/null)
}

draw_ui() {
	local cols lines lw pw ph layout top_h bot_h
	local idx kind target prev_id text mark plain padding list_lines=() prev
	local list_h offset
	layout=${MUX_TUI_LAYOUT:-stack}
	# 用 tty 的真实尺寸：tput 会受继承来的 LINES/COLUMNS 影响，可能拿到宿主尺寸而不是这个 pane 的
	size=$(stty size 2>/dev/null)
	if [ -n "$size" ]; then
		lines=${size%% *}
		cols=${size##* }
	else
		cols=80
		lines=24
	fi
	# stty size 给的就是 pane 的可写区域（浮动 pane 的边框不计入），_不要再减_
	[ "$lines" -lt 6 ] && lines=6
	[ "$cols" -lt 20 ] && cols=20
	if [ "$layout" = "split" ]; then
		lw=$(( cols * 45 / 100 ))
		pw=$(( cols - lw - 1 ))
		ph=$(( lines - 2 ))
	else
		lw=$(( cols - 1 ))
		pw=$(( cols - 1 ))
		top_h=$(( (lines - 3) * 55 / 100 ))
		bot_h=$(( lines - 3 - top_h ))
		[ "$top_h" -lt 2 ] && top_h=2
		[ "$bot_h" -lt 3 ] && bot_h=3
		ph=$bot_h
	fi
	[ "$lw" -lt 20 ] && lw=20
	[ "$pw" -lt 12 ] && pw=12
	[ "$ph" -lt 3 ] && ph=3

	# 树（可滚动：保证选中项始终可见）
	if [ "$layout" = "split" ]; then list_h=$(( lines - 2 )); else list_h=$top_h; fi
	offset=0
	if [ "$count" -gt "$list_h" ] && [ "$sel" -ge "$list_h" ]; then
		offset=$(( sel - list_h + 1 ))
	fi
	for idx in "${!items[@]}"; do
		[ "$idx" -lt "$offset" ] && continue
		[ "$idx" -ge "$((offset + list_h))" ] && break
		item=${items[$idx]}
		IFS='|' read -r kind target prev_id text mark <<< "$item"
		if [ "$kind" = "tab" ]; then
			plain="$text"
			padding=$(( lw - ${#plain} - 2 ))
			[ "$padding" -lt 0 ] && padding=0
			plain="${plain}$(printf '%*s' "$padding" '') $mark"
			if [ "$idx" -eq "$sel" ]; then
				list_lines+=("${C_SEL}${plain}${C_RST}")
			else
				list_lines+=("${C_TAB}${plain}${C_RST}")
			fi
		else
			plain="$text"
			padding=$(( lw - ${#plain} - 2 ))
			[ "$padding" -lt 0 ] && padding=0
			plain="${plain}$(printf '%*s' "$padding" '') $mark"
			if [ "$idx" -eq "$sel" ]; then
				list_lines+=("${C_SEL}${plain}${C_RST}")
			else
				list_lines+=("${C_PANE}${plain}${C_RST}")
			fi
		fi
	done

	# 预览
	prev=""
	# 预览高度按「剩余空间」算：列表实际占多少行就少给预览留多少，
	# 这样既不会在列表下方留一片空白，也能让内容多的 pane 尽量多显示
	if [ "$layout" = "split" ]; then
		ph=$(( lines - 2 ))
	else
		# -3：分隔线 1 行 + 提示行 1 行 + 预留 1 行（最后一行输出带换行会把光标推到区外触发滚动）
		ph=$(( lines - ${#list_lines[@]} - 3 ))
		[ "$ph" -lt 3 ] && ph=3
	fi
	IFS='|' read -r kind target prev_id text mark <<< "${items[$sel]}"
	if [ -n "${prev_id:-}" ] && [ "$prev_id" != "null" ]; then
		# 预览不过滤装饰行：pane 界面里的框线/图标本来就属于内容，
		# 过滤掉会让预览只剩空行（看起来「很多空」）。只做宽度截断和行数补齐。
		# 不带 -f：取「当前屏幕」而不是全历史尾部，预览才和被预览的 pane 所见一致
		prev=$(zellij action dump-screen --pane-id "$prev_id" --ansi 2>/dev/null |
			tail -n "$ph" | ansi_cut "$pw" |
			awk -v ph="$ph" '{ print } END { for (i = NR; i < ph; i++) print "" }')
	fi

	printf '\033[H\033[2J'
	if [ "$layout" = "split" ]; then
		paste -d'│' \
			<(printf '%s\n' "${list_lines[@]}") \
			<(printf '%s\n' "$prev") 2>/dev/null
	else
		# 逐行截断到区域宽度：中文 tab 名按字符数算不出的宽度差会让整行折行、把界面挤下去
		printf '%s\n' "${list_lines[@]}" | ansi_cut "$lw"
		printf '%s\n' "${C_DIM}$(printf '─%.0s' $(seq 1 "$cols"))${C_RST}"
		printf '%s\n' "$prev"
	fi
	# 提示行用光标定位钉在最后一行（比按输出行数推算可靠）
	# 末尾不能带换行，否则光标被推到下一行 → 触发滚动 → 提示行被顶上去
	# 定位到 lines-1：可写区比 stty 报的少 1 行，定到 lines 会触发滚动把列表首行顶掉
	printf '\033[%d;1H%s' "$((lines - 1))" "$(printf '%s' "${C_KEY} ↑↓/jk ${C_RST}${C_HINT}选择${C_RST} · ${C_KEY}n/p${C_RST}${C_HINT} 上/下个 tab${C_RST} · ${C_KEY}1-9${C_RST}${C_HINT} 直跳 tab${C_RST} · ${C_KEY}回车${C_RST}${C_HINT} 跳转（tab 行跳 tab、pane 行跳 pane）${C_RST} · ${C_KEY}q/Esc${C_RST}${C_HINT} 取消${C_RST}" | ansi_cut "$cols")"
}

read_key() {
	local k rest
	IFS= read -rsn1 k || { echo quit; return; }
	case "$k" in
	$'\e')
		IFS= read -rsn2 -t 0.05 rest
		case "$rest" in
		'[A') echo up ;;
		'[B') echo down ;;
		*) echo esc ;;
		esac
		;;
	'') echo enter ;;
	k | K) echo up ;;
	j | J) echo down ;;
	n | N) echo nexttab ;;
	p | P) echo prevtab ;;
	q | Q) echo quit ;;
	[1-9]) echo "digit:$k" ;;
	*) echo other ;;
	esac
}

snapshot
if [ -z "$(printf '%s' "$tabs" | jq -r '.[].tab_id' 2>/dev/null)" ]; then
	printf '拿不到 tab 列表\n'
	sleep 1.5
	close_self
	exit 0
fi

build_items
count=${#items[@]}
sel=0
printf '\033[?25l'
trap 'printf "\033[0m\033[?25h"' EXIT

while :; do
	draw_ui
	key=$(read_key)
	case "$key" in
	up) sel=$(( (sel - 1 + count) % count )) ;;
	down) sel=$(( (sel + 1) % count )) ;;
	nexttab)
		# 选到下一个 tab 行（跳过 pane 行），到末尾则回到第一个
		next=""
		for ti in "${tab_indexes[@]}"; do
			[ "$ti" -gt "$sel" ] && { next=$ti; break; }
		done
		if [ -n "$next" ]; then sel=$next; else sel=${tab_indexes[0]}; fi
		;;
	prevtab)
		# 选到上一个 tab 行，到开头则回到最后一个
		prev=""
		for ti in "${tab_indexes[@]}"; do
			[ "$ti" -lt "$sel" ] && prev=$ti
		done
		if [ -n "$prev" ]; then sel=$prev; else sel=${tab_indexes[${#tab_indexes[@]} - 1]}; fi
		;;
	digit:*)
		# 1-9 直接跳到第 N 个 tab
		d=${key#digit:}
		if [ "$d" -le "${#tab_indexes[@]}" ]; then
			sel=${tab_indexes[$((d - 1))]}
			IFS='|' read -r kind target prev_id text mark <<< "${items[$sel]}"
			if [ -n "${target:-}" ] && [ "$target" != "null" ]; then
				setsid -f sh -c "sleep 0.3; zellij action go-to-tab-by-id $target" </dev/null >/dev/null 2>&1 ||
					zellij action go-to-tab-by-id "$target" 2>/dev/null || true
			fi
		fi
		break
		;;
	enter)
		IFS='|' read -r kind target prev_id text mark <<< "${items[$sel]}"
		if [ -n "${target:-}" ] && [ "$target" != "null" ]; then
			if [ "$kind" = "tab" ]; then
				act="go-to-tab-by-id $target"
			else
				act="focus-pane-id $target"
			fi
			# 关浮动 pane 会把 client 焦点移回它覆盖的 pane，所以跳转排在关窗之后
			setsid -f sh -c "sleep 0.3; zellij action $act" </dev/null >/dev/null 2>&1 ||
				zellij action $act 2>/dev/null || true
		fi
		break
		;;
	quit | esc) break ;;
	esac
done

close_self
exit 0
