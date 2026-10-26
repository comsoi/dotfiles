#!/bin/bash
# display-panes.sh —— zellij 版 display-panes：布局地图 + 编号表，hjkl/数字选择，回车跳转。
#   zellij 画不出 tmux 那种「编号叠加在每个真实 pane 上」的层（插件和 pane 都是不透明格子），
#   所以用浮动 pane 画一张按 percent 缩放的布局地图（方框中心写编号），下方附编号表。
#   按键：hjkl 按空间方向选、数字按编号直选（编号两位零填充：01、02…09、10、11…，
#   按标签累积输入、随敲随选、回车才跳，按 1 不会再有「是 1 还是 1x」的歧义）、
#   退格改数字、回车跳转、q/Esc 取消；初始选中当前 pane。
#   编号按屏幕位置排（先上后下、先左后右）。挂在 zellij 的 `C-s s`。
# 依赖：jq；本文件在 ~/.config/zellij/scripts/，由 ~/.config/zellij/config.kdl 的 tmux 模式
# `bind "s"` 用 Run 拉起（浮动 pane）。

set -u
TAB=$(printf '\t')

# 配色（256 色）
C_RST=$'\033[0m'
C_DIM=$'\033[38;5;60m'
C_SEL=$'\033[1;38;5;231;48;5;238m'
C_TXT=$'\033[38;5;250m'
C_HEAD=$'\033[1;38;5;110m'
C_ACT=$'\033[38;5;114m'
C_KEY=$'\033[1;38;5;222m'
C_HINT=$'\033[38;5;110m'

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

panes=$(zellij action list-panes -a -j 2>/dev/null)
self_tab=$(printf '%s' "$panes" | jq -r --arg self "${ZELLIJ_PANE_ID:-}" \
	'.[] | select((.id | tostring) == $self) | .tab_position' 2>/dev/null | head -n1)
# 浮窗刚创建时可能还没进 list-panes，兜底用 active tab（= 触发时所在 tab）
[ -n "${self_tab:-}" ] || self_tab=$(zellij action list-tabs -j 2>/dev/null | jq -r '.[] | select(.active) | .position' | head -n1)

# 候选：当前 tab 的 tiled pane（排除浮窗自己），按屏幕位置排序
rows=$(printf '%s' "$panes" | jq -r --arg self "${ZELLIJ_PANE_ID:-}" --arg stab "${self_tab:-}" '
	[.[] | select(.is_plugin != true) | select(.is_floating != true)
	    | select((.id | tostring) != $self) | select((.tab_position | tostring) == $stab)]
	| sort_by(.pane_x, .pane_y)   # 与 tmux 一致：列优先（先左后右，同列内先上后下）
	| to_entries[]
	| [(.key + 1 | tostring), (.value.id | tostring), (.value.tab_name // ""),
	   (.value.pane_command // .value.title // "?"),
	   (.value.pane_x | tostring), (.value.pane_y | tostring),
	   (.value.pane_columns | tostring), (.value.pane_rows | tostring),
	   (if .value.is_focused then "1" else "0" end)] | @tsv' 2>/dev/null)

ids=(); gx=(); gy=(); gw=(); gh=(); labels=(); names=()
sel=0
while IFS="$TAB" read -r num id tabname cmd x y w h foc; do
	[ -n "${id:-}" ] || continue
	# 编号即按键：两位零填充（01、02…09、10、11…），敲什么就是什么
	labels+=("$(printf '%02d' "$num")")
	ids+=("$id"); names+=("$(printf '%s  %s' "$tabname" "$cmd")")
	gx+=("$x"); gy+=("$y"); gw+=("$w"); gh+=("$h")
	[ "$foc" = "1" ] && sel=$(( ${#ids[@]} - 1 ))   # 初始选中当前聚焦的 pane
done <<< "$rows"

count=${#ids[@]}
if [ "$count" -eq 0 ]; then
	printf '当前 tab 没有可跳的 pane\n'
	sleep 1.5
	close_self
	exit 0
fi

# 按空间方向找相邻 pane（从指定 pane 出发），纯 shell 实现（pane 数量少）
next_by_dir() {
	local cur=$1 d=$2 i ci=-1 tx ty tw th cx cy cw ch best="" bd=-1 dist ov
	for i in "${!ids[@]}"; do [ "${ids[$i]}" = "$cur" ] && ci=$i; done
	[ "$ci" -ge 0 ] || return 0
	cx=${gx[$ci]}; cy=${gy[$ci]}; cw=${gw[$ci]}; ch=${gh[$ci]}
	for i in "${!ids[@]}"; do
		[ "$i" -eq "$ci" ] && continue
		tx=${gx[$i]}; ty=${gy[$i]}; tw=${gw[$i]}; th=${gh[$i]}
		ov=1
		case "$d" in
		h) [ $((tx + tw)) -le "$cx" ] || continue
		   dist=$((cx - tx - tw))
		   { [ "$ty" -lt $((cy + ch)) ] && [ $((ty + th)) -gt "$cy" ]; } || ov=0 ;;
		l) [ "$tx" -ge $((cx + cw)) ] || continue
		   dist=$((tx - cx - cw))
		   { [ "$ty" -lt $((cy + ch)) ] && [ $((ty + th)) -gt "$cy" ]; } || ov=0 ;;
		k) [ $((ty + th)) -le "$cy" ] || continue
		   dist=$((cy - ty - th))
		   { [ "$tx" -lt $((cx + cw)) ] && [ $((tx + tw)) -gt "$cx" ]; } || ov=0 ;;
		j) [ "$ty" -ge $((cy + ch)) ] || continue
		   dist=$((ty - cy - ch))
		   { [ "$tx" -lt $((cx + cw)) ] && [ $((tx + tw)) -gt "$cx" ]; } || ov=0 ;;
		esac
		[ "$ov" = "1" ] || continue
		if [ "$bd" -lt 0 ] || [ "$dist" -lt "$bd" ]; then bd=$dist; best=${ids[$i]}; fi
	done
	[ -n "$best" ] && printf '%s' "$best"
}

draw_ui() {
	local cols lines mw pw ph layout top_h bot_h map_h i line numhint
	layout=${MUX_TUI_LAYOUT:-stack}
	size=$(stty size 2>/dev/null)
	if [ -n "$size" ]; then lines=${size%% *}; cols=${size##* }; else cols=80; lines=24; fi
	if [ "$layout" = "split" ]; then
		pw=$(( cols * 55 / 100 ))
		mw=$(( cols - pw - 1 ))
		ph=$(( lines - 2 ))
		map_h=$ph
	else
		mw=$(( cols - 1 ))
		pw=$(( cols - 1 ))
		map_h=$(( lines * 6 / 10 ))
		ph=$(( lines - map_h - 2 ))
	fi
	[ "$mw" -lt 16 ] && mw=16
	[ "$pw" -lt 16 ] && pw=16
	[ "$map_h" -lt 3 ] && map_h=3
	[ "$ph" -lt 1 ] && ph=1

	# 地图：按 geometry 缩放，选中项用 [N]
	map=$(for i in "${!ids[@]}"; do
		lbl=${labels[$i]}
		[ "$i" -eq "$sel" ] && lbl="[$lbl]"
		printf '%s\t%s\t%s\t%s\t%s\n' "${gx[$i]}" "${gy[$i]}" "${gw[$i]}" "${gh[$i]}" "$lbl"
	done | awk -F'\t' -v mw="$mw" -v mh="$map_h" '
		{ n++; x[n] = $1 + 0; y[n] = $2 + 0; w[n] = $3 + 0; h[n] = $4 + 0; lbl[n] = $5
		  if (x[n] + w[n] > W) W = x[n] + w[n]; if (y[n] + h[n] > H) H = y[n] + h[n] }
		END {
			if (n == 0) exit
			for (r = 1; r <= mh; r++) for (c = 1; c <= mw; c++) can[r, c] = " "
			for (i = 1; i <= n; i++) {
				c1 = int(x[i] * mw / W) + 1; c2 = int((x[i] + w[i]) * mw / W)
				r1 = int(y[i] * mh / H) + 1; r2 = int((y[i] + h[i]) * mh / H)
				if (c2 <= c1) c2 = c1 + 1; if (r2 <= r1) r2 = r1 + 1
				if (c2 > mw) c2 = mw; if (r2 > mh) r2 = mh
				for (c = c1; c <= c2; c++) { can[r1, c] = "─"; can[r2, c] = "─" }
				for (r = r1; r <= r2; r++) { can[r, c1] = "│"; can[r, c2] = "│" }
				can[r1, c1] = "┌"; can[r1, c2] = "┐"; can[r2, c1] = "└"; can[r2, c2] = "┘"
				if (c2 - c1 >= 3 && r2 - r1 >= 2 && lbl[i] != "") {
					st = int((c1 + c2 - length(lbl[i])) / 2) + 1
					for (k = 1; k <= length(lbl[i]); k++) can[int((r1 + r2) / 2), st + k - 1] = substr(lbl[i], k, 1)
				}
			}
			for (r = 1; r <= mh; r++) { line = ""; for (c = 1; c <= mw; c++) line = line can[r, c]; print line }
		}')
	map=$(printf '%s\n' "$map" | sed "s/\[\([0-9]*\)\]/${C_SEL}[\1]${C_RST}${C_DIM}/g; s/^/${C_DIM}/; s/\$/${C_RST}/")

	# 编号表
	tbl=""
	for i in "${!ids[@]}"; do
		if [ "$i" -eq "$sel" ]; then
			tbl="$tbl${C_SEL}$(printf '%2s) %s' "${labels[$i]}" "${names[$i]}")${C_RST}"$'\n'
		else
			tbl="$tbl${C_TXT}$(printf '%2s) %s' "${labels[$i]}" "${names[$i]}")${C_RST}"$'\n'
		fi
	done

	printf '\033[H\033[2J'
	if [ "$layout" = "split" ]; then
		paste -d'│' <(printf '%s\n' "$map") <(printf '%s' "$tbl") 2>/dev/null
	else
		printf '%s\n' "$map"
		printf '%s\n' "${C_DIM}$(printf '─%.0s' $(seq 1 "$cols"))${C_RST}"
		printf '%s' "$tbl" | head -n "$ph"
	fi
	numhint=""
	[ -n "$num_buf" ] && numhint=" · ${C_KEY}输入 ${num_buf}${C_RST}${C_HINT}"
	printf '\033[%d;1H%s' "$((lines - 1))" "$(printf '%s' "${C_KEY} hjkl ${C_RST}${C_HINT}方向选${C_RST} · ${C_KEY}数字${C_RST}${C_HINT} 按编号直选（01、02…10、11）${C_RST} · ${C_KEY}回车${C_RST}${C_HINT} 跳转${C_RST}${numhint} · ${C_KEY}q/Esc${C_RST}${C_HINT} 取消${C_RST}" | ansi_cut "$cols")"
}

read_key() {
	local k rest
	IFS= read -rsn1 k || { echo quit; return; }
	case "$k" in
	$'\e') IFS= read -rsn2 -t 0.05 rest; case "$rest" in '[A') echo dir:k ;; '[B') echo dir:j ;; '[C') echo dir:l ;; '[D') echo dir:h ;; *) echo esc ;; esac ;;
	'') echo enter ;;
	h | H) echo dir:h ;;
	j | J) echo dir:j ;;
	k | K) echo dir:k ;;
	l | L) echo dir:l ;;
	q | Q) echo quit ;;
	[0-9]) echo "digit:$k" ;;
	$'\177' | $'\b') echo backspace ;;
	*) echo other ;;
	esac
}

printf '\033[?25l'
trap 'printf "\033[0m\033[?25h"' EXIT

num_buf=""   # 数字输入缓冲：编号两位零填充（01、02…09、10、11…），按标签累积敲入
while :; do
	draw_ui
	key=$(read_key)
	case "$key" in
	dir:*)
		num_buf=""
		d=${key#dir:}
		target=$(next_by_dir "${ids[$sel]}" "$d")
		if [ -n "$target" ]; then
			for i in "${!ids[@]}"; do [ "${ids[$i]}" = "$target" ] && { sel=$i; break; }; done
		fi
		;;
	digit:*)
		# 数字累积：编号是两位零填充的十进制（01→1 号、10→10 号），按标签敲即可；
		# 合法值随敲随选（高亮即预览，回车才跳），超范围就把最后一位当新输入。
		d=${key#digit:}
		num_buf="${num_buf}${d}"
		if [ "$num_buf" -ge 1 ] && [ "$num_buf" -le "$count" ]; then
			sel=$((10#$num_buf - 1))
		elif [ "$d" -ge 1 ] && [ "$d" -le "$count" ]; then
			num_buf="$d"
			sel=$((d - 1))
		else
			num_buf=""
		fi
		;;
	backspace)
		num_buf=${num_buf%?}
		if [ -n "$num_buf" ] && [ "$num_buf" -le "$count" ]; then
			sel=$((10#$num_buf - 1))
		fi
		;;
	enter)
		if [ -n "$num_buf" ]; then
			# 缓冲里有数字：只有合法编号才跳，否则清掉重来（别跳错 pane）
			if [ "$num_buf" -ge 1 ] && [ "$num_buf" -le "$count" ]; then
				sel=$((10#$num_buf - 1))
			else
				num_buf=""
				continue
			fi
		fi
		target=${ids[$sel]}
		setsid -f sh -c "sleep 0.3; zellij action focus-pane-id $target" </dev/null >/dev/null 2>&1 ||
			zellij action focus-pane-id "$target" 2>/dev/null || true
		break
		;;
	quit | esc) break ;;
	esac
done

close_self
exit 0
