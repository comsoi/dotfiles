#!/bin/bash
# swap-pane.sh —— zellij 版 swap-pane：自绘 TUI（左布局地图 + 右内容预览），回车换位。
#   zellij 既没有 display-panes 也没有 swap action，所以这里自己画界面：
#     左半：用 list-panes 的 geometry 按比例画当前 tab 的布局地图
#           （候选标 1..N，当前 pane 标 *，当前选中项用 [N] 包住）
#     右半：实时预览选中 pane 的内容
#     ↑↓ / jk 选择 · 回车把选中的 pane 搬到当前 pane 的位置 · q 或 Esc 取消
#   搬运用 `zellij action move-pane --pane-id <id> <dir>`（方向是位置参数），实测位置和尺寸
#   会一起互换，效果等价 tmux 的 `swap-pane -t`。挂在 zellij 的 `C-s S`。
# 依赖：jq；本文件在 ~/.config/zellij/scripts/，由 ~/.config/zellij/config.kdl 的 tmux 模式
# `bind "S"` 用 Run 拉起（浮动 pane）。

set -u
TAB=$(printf '\t')
MUX_FIND_LINES=${MUX_FIND_LINES:-2000}

# 配色（256 色）
C_RST=$'\033[0m'
C_DIM=$'\033[38;5;60m'    # 地图框线
C_SEL=$'\033[1;38;5;231;48;5;238m'   # 选中的 pane 编号
C_KEY=$'\033[1;38;5;222m' # 提示里的按键
C_HINT=$'\033[38;5;110m'  # 提示文字

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

panes=$(zellij action list-panes -a -j 2>/dev/null)
self_tab=$(printf '%s' "$panes" | jq -r --arg self "${ZELLIJ_PANE_ID:-}" \
	'.[] | select((.id | tostring) == $self) | .tab_position' 2>/dev/null | head -n1)
# source = 触发时聚焦的那个 tiled pane（浮动 pane 抢焦点时，原 tiled pane 的 is_focused 仍是 true）
# 浮窗刚创建时可能还没进 list-panes，兜底用 active tab（= 触发时所在 tab）
[ -n "${self_tab:-}" ] || self_tab=$(zellij action list-tabs -j 2>/dev/null | jq -r '.[] | select(.active) | .position' | head -n1)
source_id=$(printf '%s' "$panes" | jq -r --arg stab "${self_tab:-}" '
	.[] | select(.is_plugin != true) | select(.is_floating != true)
	| select((.tab_position | tostring) == $stab) | select(.is_focused) | .id' 2>/dev/null | head -n1)

close_self() {
	printf '\033[0m\033[?25h'
	[ -n "${ZELLIJ_PANE_ID:-}" ] && zellij action close-pane --pane-id "$ZELLIJ_PANE_ID" 2>/dev/null
}

if [ -z "${source_id:-}" ]; then
	close_self
	exit 0
fi

# 候选：当前 tab 的其它 tiled pane（不跨 tab）
mapfile -t ids < <(printf '%s' "$panes" | jq -r --arg self "${ZELLIJ_PANE_ID:-}" --arg stab "${self_tab:-}" --arg src "$source_id" '
	[.[] | select(.is_plugin != true) | select(.is_floating != true)
	| select((.id | tostring) != $self) | select((.id | tostring) != $src)
	| select((.tab_position | tostring) == $stab)]
	| sort_by(.pane_x, .pane_y)      # 与 tmux 一致：列优先（先左后右，同列内先上后下）
	| .[].id' 2>/dev/null)

if [ "${#ids[@]}" -eq 0 ]; then
	printf '当前 tab 没有其它可交换的 pane\n'
	sleep 1.5
	close_self
	exit 0
fi

# 当前 tab 的 tiled pane 几何（tsv: id x y w h）
pane_geom() {
	printf '%s' "$panes" | jq -r --arg stab "${self_tab:-}" '
		.[] | select(.is_plugin != true) | select(.is_floating != true)
		| select((.tab_position | tostring) == $stab)
		| [(.id | tostring), (.pane_x | tostring), (.pane_y | tostring),
		   (.pane_columns | tostring), (.pane_rows | tostring)] | @tsv' 2>/dev/null
}

# 按空间方向找相邻 pane：$1=当前 pane id，$2=h/j/k/l → 输出目标 pane id（没有则空）
next_by_dir() {
	pane_geom | awk -F'\t' -v cur="$1" -v d="$2" '
		{ id[NR] = $1; x[NR] = $2; y[NR] = $3; w[NR] = $4; h[NR] = $5; if ($1 == cur) ci = NR }
		END {
			if (!ci) exit
			cx = x[ci]; cy = y[ci]; cw = w[ci]; ch = h[ci]
			best = ""; bd = -1
			for (i = 1; i <= NR; i++) {
				if (i == ci) continue
				tx = x[i]; ty = y[i]; tw = w[i]; th = h[i]
				ok = 0; dist = 0
				if (d == "h")      { if (tx + tw <= cx) { ok = 1; dist = cx - (tx + tw) } }
				else if (d == "l") { if (tx >= cx + cw) { ok = 1; dist = tx - (cx + cw) } }
				else if (d == "k") { if (ty + th <= cy) { ok = 1; dist = cy - (ty + th) } }
				else if (d == "j") { if (ty >= cy + ch) { ok = 1; dist = ty - (cy + ch) } }
				if (!ok) continue
				# 该方向上必须有投影重叠，否则只是斜对角
				if (d == "h" || d == "l") { if (!(ty < cy + ch && ty + th > cy)) continue }
				else                      { if (!(tx < cx + cw && tx + tw > cx)) continue }
				if (bd < 0 || dist < bd) { bd = dist; best = id[i] }
			}
			if (best != "") print best
		}'
}

# 取某个 pane 的坐标 "x y"
xy_of() {
	zellij action list-panes -a -j 2>/dev/null | jq -r --arg p "$1" \
		'.[] | select((.id | tostring) == $p) | "\(.pane_x) \(.pane_y)"' 2>/dev/null | head -n1
}

# 把某个 pane 沿方向逐步挪到目标坐标；每一步 move-pane 都是一次「与相邻 pane 互换」
# 执行过的步骤记进全局数组 MOVES，失败时可以原路退回
MOVES=()
move_pane_to_xy() {
	local pane=$1 wx=$2 wy=$3 i=0 prev="" cur cx cy dir
	while [ "$i" -lt 16 ]; do
		i=$((i + 1))
		cur=$(xy_of "$pane")
		[ -z "$cur" ] && break
		[ "$cur" = "$wx $wy" ] && break
		[ "$cur" = "$prev" ] && break
		prev=$cur
		cx=${cur%% *}; cy=${cur##* }
		if   [ "$cy" -lt "$wy" ]; then dir=down
		elif [ "$cy" -gt "$wy" ]; then dir=up
		elif [ "$cx" -lt "$wx" ]; then dir=right
		elif [ "$cx" -gt "$wx" ]; then dir=left
		else break; fi
		MOVES+=("$pane:$dir")
		zellij action move-pane --pane-id "$pane" "$dir" 2>/dev/null || break
	done
}

# 尝试交换：先把 target 搬到 source 原位，再把 source 搬到 target 原位。
# 注意 move-pane 与哪个邻居交换是 zellij 内部决定的（非对称布局下可能选到第三个 pane），
# 所以做完必须校验：只有两者真的对调才算成功，否则原路退回（保证布局不被搞乱）。
swap_with() {
	local target=$1 sxy txy i p d rev
	sxy=$(xy_of "$source_id")
	txy=$(xy_of "$target")
	[ -n "$sxy" ] && [ -n "$txy" ] || return 0
	MOVES=()
	move_pane_to_xy "$target" "${sxy%% *}" "${sxy##* }"
	move_pane_to_xy "$source_id" "${txy%% *}" "${txy##* }"
	# 校验：两个 pane 是否真的互换了原位
	if [ "$(xy_of "$target")" = "$sxy" ] && [ "$(xy_of "$source_id")" = "$txy" ]; then
		return 0
	fi
	# 没成功 → 反向退回（move-pane 可逆）
	for ((i = ${#MOVES[@]} - 1; i >= 0; i--)); do
		p=${MOVES[$i]%%:*}; d=${MOVES[$i]##*:}
		case "$d" in
		up) rev=down ;; down) rev=up ;; left) rev=right ;; right) rev=left ;;
		esac
		zellij action move-pane --pane-id "$p" "$rev" 2>/dev/null || true
	done
	return 1
}

# 把目标 pane 逐格搬到 source 原来的位置（两者互换）
move_pane_to_source() {
	local target=$1 i=0 prev="" src_geom cur_geom dir
	src_geom=$(zellij action list-panes -a -j 2>/dev/null |
		jq -r --arg s "$source_id" '.[] | select((.id | tostring) == $s) | "\(.pane_x),\(.pane_y)"' 2>/dev/null | head -n1)
	[ -n "$src_geom" ] || return 0
	while [ "$i" -lt 12 ]; do
		i=$((i + 1))
		cur_geom=$(zellij action list-panes -a -j 2>/dev/null |
			jq -r --arg t "$target" '.[] | select((.id | tostring) == $t) | "\(.pane_x),\(.pane_y)"' 2>/dev/null | head -n1)
		[ -z "$cur_geom" ] && break
		[ "$cur_geom" = "$src_geom" ] && break          # 已落到 source 原位 = 互换完成
		[ "$cur_geom" = "$prev" ] && break              # 上一步没位移，别再空转
		prev=$cur_geom
		dir=$(zellij action list-panes -a -j 2>/dev/null | jq -r --arg t "$target" --arg s "$source_id" '
			([.[] | select((.id | tostring) == $t)] | first) as $T
			| ([.[] | select((.id | tostring) == $s)] | first) as $S
			| if ($T == null or $S == null) then "done"
			  elif ($T.pane_x == $S.pane_x and $T.pane_y == $S.pane_y) then "done"
			  else
			    ((($T.pane_x - $S.pane_x) | if . < 0 then -. else . end) as $dx
			     | (($T.pane_y - $S.pane_y) | if . < 0 then -. else . end) as $dy
			     | if $dx >= $dy
			       then (if $T.pane_x < $S.pane_x then "right" else "left" end)
			       else (if $T.pane_y < $S.pane_y then "down" else "up" end) end)
			  end' 2>/dev/null | head -n1)
		[ -z "$dir" ] && break
		[ "$dir" = "done" ] && break
		zellij action move-pane --pane-id "$target" "$dir" 2>/dev/null || break
	done
}

# 画一帧：左地图 + 右预览
draw_ui() {
	local cols lines mw pw ph sel_id ids_json map prev
	local layout=${MUX_TUI_LAYOUT:-stack} top_h bot_h map_h
	cols=$(tput cols 2>/dev/null || echo 80)
	lines=$(tput lines 2>/dev/null || echo 24)
	# 用 tty 的真实尺寸：tput 会受继承来的 LINES/COLUMNS 影响，可能拿到宿主尺寸而不是这个 pane 的
	size=$(stty size 2>/dev/null)
	if [ -n "$size" ]; then
		lines=${size%% *}
		cols=${size##* }
	fi
	# stty size 给的就是 pane 的可写区域（浮动 pane 的边框不计入），_不要再减_
	[ "$lines" -lt 6 ] && lines=6
	[ "$cols" -lt 20 ] && cols=20
	if [ "$layout" = "split" ]; then
		pw=$(( cols * 45 / 100 ))      # 预览宽（右）
		mw=$(( cols - pw - 1 ))        # 地图宽（左）
		ph=$(( lines - 2 ))            # 预览高
		map_h=$ph
	else
		mw=$(( cols - 1 ))             # 地图占满宽度（上）
		pw=$(( cols - 1 ))             # 预览也占满宽度（下）
		top_h=$(( (lines - 3) * 55 / 100 ))
		bot_h=$(( lines - 3 - top_h ))
		[ "$top_h" -lt 3 ] && top_h=3
		[ "$bot_h" -lt 3 ] && bot_h=3
		ph=$bot_h                      # 预览高（下）
		map_h=$top_h
	fi
	[ "$mw" -lt 16 ] && mw=16
	[ "$pw" -lt 12 ] && pw=12
	[ "$ph" -lt 3 ] && ph=3
	sel_id=$cursor

	# 地图：jq 负责缩放几何，awk 只负责画框和写标签
	ids_json=$(printf '%s\n' "${ids[@]}" | jq -R . | jq -s -c .)
	map=$(printf '%s' "$panes" | jq -r --arg stab "${self_tab:-}" --arg src "$source_id" \
		--arg sid "$sel_id" --argjson ids "$ids_json" --argjson mw "$mw" --argjson mh "$ph" '
		[.[] | select(.is_plugin != true) | select(.is_floating != true)
		    | select((.tab_position | tostring) == $stab)] as $P
		| (($P | map(.pane_x + .pane_columns) | max) // 1) as $W
		| (($P | map(.pane_y + .pane_rows) | max) // 1) as $H
		| $P[] | (.id | tostring) as $pid
		| ($ids | index($pid)) as $i
		| [ ((.pane_x * $mw / $W | floor) + 1),
		    ((.pane_x + .pane_columns) * $mw / $W | floor),
		    ((.pane_y * $mh / $H | floor) + 1),
		    ((.pane_y + .pane_rows) * $mh / $H | floor),
		    (if $i == null then " " else (($i + 1) | tostring) end),
		    ($pid == $sid) ] | @tsv' 2>/dev/null |
		awk -F"\t" -v mw="$mw" -v mh="$map_h" '
			{ n++; c1[n] = $1 + 0; c2[n] = $2 + 0; r1[n] = $3 + 0; r2[n] = $4 + 0; lbl[n] = $5; sel[n] = $6 }
			END {
				if (n == 0) exit
				for (r = 1; r <= mh; r++) for (c = 1; c <= mw; c++) can[r, c] = " "
				for (i = 1; i <= n; i++) {
					if (c1[i] < 1) c1[i] = 1; if (r1[i] < 1) r1[i] = 1
					if (c2[i] <= c1[i]) c2[i] = c1[i] + 1
					if (r2[i] <= r1[i]) r2[i] = r1[i] + 1
					if (c2[i] > mw) c2[i] = mw
					if (r2[i] > mh) r2[i] = mh
					for (c = c1[i]; c <= c2[i]; c++) { can[r1[i], c] = "─"; can[r2[i], c] = "─" }
					for (r = r1[i]; r <= r2[i]; r++) { can[r, c1[i]] = "│"; can[r, c2[i]] = "│" }
					can[r1[i], c1[i]] = "┌"; can[r1[i], c2[i]] = "┐"
					can[r2[i], c1[i]] = "└"; can[r2[i], c2[i]] = "┘"
					if (c2[i] - c1[i] >= 3 && r2[i] - r1[i] >= 2 && lbl[i] != " ") {
						s = (sel[i] == "true") ? "[" lbl[i] "]" : lbl[i]
						st = int((c1[i] + c2[i] - length(s)) / 2) + 1
						for (k = 1; k <= length(s); k++) can[int((r1[i] + r2[i]) / 2), st + k - 1] = substr(s, k, 1)
					}
				}
				for (r = 1; r <= mh; r++) {
					line = ""
					for (c = 1; c <= mw; c++) line = line can[r, c]
					print line
				}
			}' 2>/dev/null)

	# 预览：选中 pane 的可见内容（**不**过滤装饰行 —— 框线/图标是内容的一部分，
	# 过滤掉会让预览只剩空行），只做宽度截断和行数补齐
	# 预览高度按剩余空间算，地图下方不留空白（-3：分隔线 + 提示 + 预留 1 行防滚动）
	ph=$(( lines - map_h - 3 ))
	[ "$ph" -lt 3 ] && ph=3
	# 不带 -f：取「当前屏幕」而不是全历史尾部
	prev=$(zellij action dump-screen --pane-id "$sel_id" --ansi 2>/dev/null |
		tail -n "$ph" | ansi_cut "$pw" |
		awk -v ph="$ph" '{ print } END { for (i = NR; i < ph; i++) print "" }')

	# 地图上色：整体暗色，选中项 [N] 高亮
	# 注意：C_SEL 带背景色，换回普通色时必须先 reset，否则底色会一直染到行尾
	map=$(printf '%s\n' "$map" |
		sed "s/\[$((sel + 1))\]/${C_SEL}[$((sel + 1))]${C_RST}${C_DIM}/g; s/^/${C_DIM}/; s/\$/${C_RST}/")

	printf '\033[H\033[2J'
	if [ "$layout" = "split" ]; then
		paste -d'│' <(printf '%s\n' "$map") <(printf '%s\n' "$prev") 2>/dev/null
	else
		printf '%s\n' "$map"
		printf '%s\n' "$(printf '─%.0s' $(seq 1 "$cols"))"
		printf '%s\n' "$prev"
	fi
	# 提示行用光标定位钉在最后一行
	# 末尾不能带换行，否则光标被推到下一行 → 触发滚动 → 提示行被顶上去
	# 定位到 lines-1：可写区比 stty 报的少 1 行
	printf '\033[%d;1H%s' "$((lines - 1))" "$(printf '%s' "${C_KEY} hjkl ${C_RST}${C_HINT}方向选择${C_RST} · ${C_KEY}1-9${C_RST}${C_HINT} 直选${C_RST} · ${C_KEY}回车${C_RST}${C_HINT} 换到当前位置${C_RST} · ${C_KEY}q/Esc${C_RST}${C_HINT} 取消${C_RST}" | ansi_cut "$cols")"
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
	h | H) echo dir:h ;;
	j | J) echo dir:j ;;
	k | K) echo dir:k ;;
	l | L) echo dir:l ;;
	q | Q) echo quit ;;
	[1-9]) echo "digit:$k" ;;
	*) echo other ;;
	esac
}

# cursor = 光标所在的 pane（初始在自己身上）；sel = 候选下标，-1 表示光标在自己身上（不能交换）
sel=-1
cursor=$source_id
printf '\033[?25l'
trap 'printf "\033[0m\033[?25h"' EXIT

while :; do
	panes=$(zellij action list-panes -a -j 2>/dev/null)
	draw_ui
	key=$(read_key)
	case "$key" in
	dir:*)
		# 按空间方向选相邻 pane（h/j/k/l）
		d=${key#dir:}
		# 两级回退：① 先从 source（触发时你所在的 pane）出发 —— 按 l 就是「选我右边那个」；
		# ② source 那个方向没有 pane 时，改成从当前选中项出发，这样能在候选之间继续游走。
		# 与 s 一致：始终从「当前选中项」出发，可以在候选之间连续游走
		target=$(next_by_dir "$cursor" "$d")
		if [ -n "$target" ]; then
			cursor=$target
			sel=-1
			for i in "${!ids[@]}"; do
				[ "${ids[$i]}" = "$target" ] && { sel=$i; break; }
			done
		fi
		;;
	digit:*)
		# 1-9 直接选中第 N 个候选
		d=${key#digit:}
		if [ "$d" -le "${#ids[@]}" ]; then
			sel=$((d - 1))
			cursor=${ids[$sel]}
		fi
		;;
	enter)
		# sel = -1 表示光标还在自己身上（没选中别人）→ 没有可交换的对象
		if [ "$sel" -lt 0 ]; then
			break
		fi
		swap_with "${ids[$sel]}"
		break
		;;
	quit | esc) break ;;
	esac
done

close_self
exit 0
