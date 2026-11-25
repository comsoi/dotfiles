local wezterm = require("wezterm")
local adapter = require("style.tabline.adapter")
local pane_proc_cache = require("utils.pane_proc_cache")
local config_overrides = require("utils.config_overrides")
local builtin_schemes = require("utils.builtin_schemes")

-- zellij 风格的标签栏溢出折叠：
-- 标签总宽超过可用宽度时，优先保留活动标签并向两侧扩展，
-- 放不下的左侧标签折叠为 " ← +N "，右侧折叠为 " +N → "（挂在最外侧可见标签上）。
-- 窄窗口下的优先级：两侧指示器完整 > 活动标签内容 > 一段间隙 > 右侧状态栏
-- （右状态放不下时整段隐藏，见 apply_right_status_control）；
-- 极端窄时标签区整段让位，左段保持完整——workspace 名只在窗口物理宽度
-- 连完整左段都放不下时才消失（带回差防频闪）。
--
-- 注意：wezterm 对 format-tab-title 只执行第一个注册的 handler，因此本模块必须在
-- tabline.setup() 之前 apply；handler 内部再手动调用 tabline 的渲染函数，样式与原来一致。
-- 依据（源码，不是推测）：
--   wezterm-gui/src/tabbar.rs 的 call_format_tab_title() 用 config::lua::emit_sync_callback
--   发 "format-tab-title"；而 config/src/lua.rs 的 emit_sync_callback 是
--     for func in tbl.sequence_values() { let func = func?; return func.call(args); }
--   —— 循环体第一句就 return，所以只有第一个 handler 会跑，它的返回值就是结果。
-- 同一处还有两条用得上：
--   * 返回 nil ⇒ wezterm 用**内建**标题（本模块的渲染兜底正是靠这条）
--   * handler 抛异常只 log::warn 一行就回退内建标题（所以出错时界面表现为"标题变了"）
-- 本机核对于 build 20261001-012714-20b645c1 + 上游 main 的上述两个文件。

local M = {}

-- 右侧状态栏完整显示时的预留宽度（cpu + datetime + battery + domain 及分隔符）；
-- 空间不足时右状态整段隐藏，该预留随即释放给标签区
M.reserve_right = 42
-- 左侧状态栏固定部分预留（mode 区块 + 分隔符等），workspace 名长度按调用时实际值追加
M.reserve_left = 18
-- 安全余量（leader 指示等临时出现的区块）
M.reserve_margin = 2
-- 标签区与右状态之间的最小间隙（仅右状态显示时保留；隐藏后无需分隔，标签填满至右缘）
M.gap = 1
-- 活动标签至少应分到的内容宽度；达不到即判定右状态"确实无法显示"
M.min_active = 8
-- 右状态恢复显示所需的额外余量（回差）：防止边界宽度下显隐每秒来回跳
M.unhide_margin = 3
-- 置 true 后通过 wezterm.log_info 输出折叠计算过程
M.debug = false

-- 每个窗口的右状态显隐决定（format-tab-title 计算，update-status 消费）：
-- [window_id] = { hide_right = bool }
M.window_state = {}

local function left_indicator(count)
	return " ← +" .. count .. " "
end

local function right_indicator(count)
	return " +" .. count .. " → "
end

-- 纯布局逻辑（可单测）：widths 为每个标签的渲染宽度（格数），active 为活动标签下标（1-based），
-- avail 为标签区可用宽度。返回 visible 集合、左/右隐藏数、最左/最右可见下标。
function M._layout(widths, active, avail)
	local n = #widths
	if n == 0 then
		return {}, 0, 0, 0, 0
	end
	local visible = {}
	local total = 0
	for i = 1, n do
		visible[i] = true
		total = total + widths[i]
	end
	if total <= avail then
		return visible, 0, 0, 1, n
	end

	for i = 1, n do
		visible[i] = nil
	end
	visible[active] = true
	local used = widths[active]

	-- 从活动标签向两侧扩展，先右后左交替，直到预算耗尽
	local li, ri = active - 1, active + 1
	while true do
		local added = false
		if ri <= n and used + widths[ri] <= avail then
			visible[ri] = true
			used = used + widths[ri]
			ri = ri + 1
			added = true
		end
		if li >= 1 and used + widths[li] <= avail then
			visible[li] = true
			used = used + widths[li]
			li = li - 1
			added = true
		end
		if not added then
			break
		end
	end

	-- 隐藏侧需要指示器宽度，不够则从离活动标签最远的一端继续收缩
	while true do
		local leftmost, rightmost
		for i = 1, n do
			if visible[i] then
				leftmost = leftmost or i
				rightmost = i
			end
		end
		leftmost = leftmost or active
		rightmost = rightmost or active
		local hidden_left = leftmost - 1
		local hidden_right = n - rightmost
		local need = used
		if hidden_left > 0 then
			need = need + wezterm.column_width(left_indicator(hidden_left))
		end
		if hidden_right > 0 then
			need = need + wezterm.column_width(right_indicator(hidden_right))
		end
		if need <= avail then
			return visible, hidden_left, hidden_right, leftmost, rightmost
		end
		-- 移除离活动标签最远的一个可见标签（平局取右侧）
		local best, best_d = nil, -1
		for i = 1, n do
			if visible[i] and i ~= active then
				local d = math.abs(i - active)
				if d >= best_d then
					best, best_d = i, d
				end
			end
		end
		if not best then
			-- 窗口过窄，只剩活动标签也放不下，交给 wezterm 自身截断
			return visible, hidden_left, hidden_right, leftmost, rightmost
		end
		visible[best] = nil
		used = used - widths[best]
	end
end

-- 活动标签限宽（可单测）：为最坏情况的两侧指示器预留空间，
-- 超出预算的部分由活动标签内容截断吸收，指示器宽度永不被侵占。
-- 返回新的 widths 表（仅在需要收缩时复制，否则原样返回）
function M._fit(widths, active, avail, worst_ind)
	local budget = math.max(avail - worst_ind, 1)
	if widths[active] <= budget then
		return widths
	end
	local copy = {}
	for i, v in ipairs(widths) do
		copy[i] = v
	end
	copy[active] = budget
	return copy
end

local function items_width(items)
	if type(items) == "string" then
		return wezterm.column_width(items)
	end
	local w = 0
	for _, item in ipairs(items or {}) do
		if type(item) == "string" then
			w = w + wezterm.column_width(item)
		elseif type(item) == "table" and item.Text then
			w = w + wezterm.column_width(item.Text)
		end
	end
	return w
end

-- 剥出标签 item 列表的收尾箭头：tabline 生成的标签末尾固定是
-- [若干属性 item] + 一个分隔符 Text（powerline 右缘箭头）。
-- 注意 tabs.lua 的命名反直觉：末尾插的是 tab_separators.left（右缘箭头），
-- 开头插的是 tab_separators.right，这里两个 glyph 都认。
-- 返回内容区末尾下标和收尾序列；没有匹配到则收尾序列为 nil
local function peel_trailing_separator(items)
	local n = #items
	local last = items[n]
	if type(last) ~= "table" or not last.Text then
		return n, nil
	end
	local sep_l, sep_r = adapter.tab_separators()
	if last.Text ~= sep_l and last.Text ~= sep_r then
		return n, nil
	end
	local tail = { last }
	local i = n - 1
	while i >= 1 do
		local it = items[i]
		if type(it) == "table" and not it.Text then
			table.insert(tail, 1, it)
			i = i - 1
		else
			break
		end
	end
	return i, tail
end

-- 按单元格数截断 FormatItem 列表（UTF-8/宽字符安全），用于约束单个超长标签；
-- 截断只作用于内容区，右缘 powerline 箭头始终保留在末尾。
-- 这里 items 一定是表：调用点用 items_width(items) 做了门（它把 nil 量成 0，进不来）。
-- 原来这里判的是 `type(items) == "string"` —— 那个分支永远不成立（插件 set_title 只可能返回
-- tabs() 生成的表，或 tabs_enabled=false 时的 nil）。
local function truncate_items(items, max_cells)
	local content_end, tail = peel_trailing_separator(items)
	local tail_w = tail and wezterm.column_width(tail[#tail].Text) or 0
	local budget = math.max(max_cells - tail_w, 0)
	local out, used = {}, 0
	for k = 1, content_end do
		local item = items[k]
		if type(item) == "table" and item.Text then
			local w = wezterm.column_width(item.Text)
			if used + w > budget then
				local remain = budget - used
				if remain > 0 then
					table.insert(out, { Text = wezterm.truncate_right(item.Text, remain) })
				end
				break
			end
			used = used + w
		end
		table.insert(out, item)
	end
	if tail then
		for _, t in ipairs(tail) do
			table.insert(out, t)
		end
	end
	return out
end

-- 指示器的两个颜色 item。FormatItem 是 Rust 端单键枚举表，Foreground/Background 必须拆成
-- 两个 item。做成按需构建：这段在每个 tab 的每次重绘里都跑，两侧都没折叠时不该有分配。
local function indicator_colors(colors)
	return { Foreground = { Color = colors.normal_mode.b.fg } },
		{ Background = { Color = colors.tab.inactive.bg } }
end

local function tabline_ok()
	return adapter.available()
end

local function render_tab(tab, hover)
	return adapter.render_tab(tab, hover)
end

-- 渲染缓存：format-tab-title 每轮重绘对每个标签各调一次，布局测宽若每回
-- 都渲染全部标签，一轮重绘就是 O(N²) 次 tabline 渲染（每次 set_title 还会
-- 重建插件内部属性表）。以影响渲染结果的全部字段为签名缓存，签名不变即复用
local render_cache = {} -- [tab_id] = { sig=string, items=table, width=number }

local function tab_signature(t)
	local p = t.active_pane or {}
	local zoomed = false
	for _, pane in ipairs(t.panes or {}) do
		if pane.is_zoomed then
			zoomed = true
			break
		end
	end
	local cwd = p.current_working_dir
	return table.concat({
		t.tab_index,
		t.is_active and "1" or "0",
		t.tab_title or "",
		p.title or "",
		p.foreground_process_name or "",
		p.domain_name or "",
		cwd and (cwd.file_path or tostring(cwd)) or "",
		zoomed and "1" or "0",
	}, "\31")
end

-- 渲染并测宽（带缓存）；返回 items, width
local function render_cached(t)
	local id = t.tab_id
	-- 插件有活动扩展时**完全绕开缓存**（不读也不写）。
	-- 扩展会临时改写 sections —— 比如工作区切换浮层把 tab_active/tab_inactive 换成空表，
	-- tabline 的 tabs() 于是返回空列表 —— 而 tab_signature 只看 tab/pane 状态，看不到这个。
	-- 不绕的话两头都错：浮层期间命中旧缓存会让 tab 继续显示旧标题（插件本意是清空）；
	-- 而一旦签名在此期间变化，空列表就被写进缓存，浮层关掉后那个 tab 会一直空着，
	-- 直到它的标题/cwd/进程名再变一次。
	if adapter.extensions_active() then
		local items = render_tab(t, false)
		return items, items_width(items)
	end
	local sig = tab_signature(t)
	local c = id and render_cache[id]
	if c and c.sig == sig then
		return c.items, c.width
	end
	local items = render_tab(t, false)
	local w = items_width(items)
	if id then
		render_cache[id] = { sig = sig, items = items, width = w }
	end
	return items, w
end

-- 窗口列数缓存：同一轮重绘里 N 个标签各触发一次 format-tab-title，
-- 列数在 window-resized 及每个 update-status 周期时失效（防字体缩放漏事件）
local cols_cache = {} -- [window_id] = cols

-- 标签栏与标签内容同宽：取该窗口活动标签的列数（MuxTab:get_size 有 cols；
-- 注意 window:get_dimensions() 只有像素值，没有 cols）
local function window_cols(window_id)
	local cached = cols_cache[window_id]
	if cached then
		return cached
	end
	local ok, mux_win = pcall(wezterm.mux.get_window, window_id)
	if not ok or not mux_win then
		return nil
	end
	local tab = mux_win:active_tab()
	if not tab then
		return nil
	end
	local ok2, size = pcall(function()
		return tab:get_size()
	end)
	if not ok2 or not size then
		return nil
	end
	cols_cache[window_id] = size.cols
	return size.cols
end

-- 测量失败只报一次。失败会静默退回固定预留（M.reserve_left / M.reserve_right），布局仍然
-- 能用但会偏，事后极难看出原因。不写文件——用 Leader+F12 的 ShowDebugOverlay 看。
local measure_warned = false

-- 实测左右状态栏宽度：用代理对象拦截 tabline 实际调用的
-- set_left_status/set_right_status 字符串（含 SGR 转义），剥掉转义后按单元格计量。
-- 这就是真实渲染宽度——分隔符、padding、组件显隐全部由插件自身逻辑决定。
local function measure_status_widths(window)
	local component = adapter.component()
	if not component or type(component.set_status) ~= "function" then
		-- 故意不报：插件还没 setup 完是启动时的正常瞬态，下一个 tick 就好了
		return nil
	end
	local left_s, right_s
	local probe = setmetatable({}, {
		__index = function(_, k)
			if k == "set_left_status" then
				return function(_, s)
					left_s = s
				end
			elseif k == "set_right_status" then
				return function(_, s)
					right_s = s
				end
			end
			local v = window[k]
			if type(v) == "function" then
				return function(_, ...)
					return v(window, ...)
				end
			end
			return v
		end,
	})
	local ok2, err2 = pcall(component.set_status, probe)
	if not ok2 then
		-- 插件已就绪却仍抛异常 = 真异常，值得报（只报一次）
		if not measure_warned then
			measure_warned = true
			wezterm.log_warn(
				"tab_collapse: 状态栏宽度测量失败（后续同样错误不再重复报告），已退回固定预留: " .. tostring(err2)
			)
		end
		return nil
	end
	local function text_width(s)
		-- wezterm.format 输出冒号分隔的 SGR（如 \27[38:2::r:g:bm）和 \27(B 字符集序列
		s = s:gsub("\027%[[0-9;:]*m", ""):gsub("\027%(.", "")
		return wezterm.column_width(s)
	end
	-- 左右分别校验：右段被掏空隐藏期间 right_s 为空串，不应连累左宽度的更新。
	-- 失真保护：测量结果明显异常（转义没剥干净等）时该侧回退上次值/固定预留
	local lw = left_s and text_width(left_s) or 0
	local rw = right_s and text_width(right_s) or 0
	if lw <= 0 or lw > 80 then
		lw = nil
	end
	if rw <= 0 or rw > 80 then
		rw = nil
	end
	return lw, rw
end

-- bar 底色（右状态隐藏时整行填充用）：取 tabline 的“环境色” colors.<mode>.c.bg——
-- 插件自己的 apply_to_config 也是拿它当 colors.tab_bar.background。
-- 它是唯一和 tab 两端 powerline 端头同色的值（端头背景 = colors.tab.inactive.bg，
-- Catppuccin 默认主题下二者同源同值 = mantle #181825），所以整行填实后不会露色块。
-- 注意：不能用 scheme 的 tab_bar.background（crust，wezterm 自带 tab bar 的底色，
-- 与 tabline 端头不同源）；也不能把它设成透明——wezterm 画 tab bar 单元格背景时
-- 不认 alpha，rgba(0,0,0,0) 会当黑色画出来。
-- 插件调色板要等 tabline.setup() 之后才有（本函数在 setup 之前执行），故运行时惰性取值。
local bar_bg
local scheme_bar_bg
local config_bar_bg

local function resolve_bar_bg()
	if bar_bg then
		return bar_bg
	end
	bar_bg = adapter.bar_bg()
	return bar_bg or scheme_bar_bg
end

function M.apply(config)
	local scheme = builtin_schemes.one(config.color_scheme)
	-- 兜底：插件调色板还没就绪时，按插件的同一套公式取（inactive_tab.bg_color）
	local tb = scheme and scheme.tab_bar
	scheme_bar_bg = (tb and tb.inactive_tab and tb.inactive_tab.bg_color) or (scheme and scheme.background)
	-- 恢复显示时用回 config 里的底色（appearance.lua，默认透明）——
	-- set_config_overrides 会整体替换 colors，置 nil 只会退回 scheme 的值，
	-- 所以这里显式读 config，避免在代码里写死颜色
	config_bar_bg = config.colors and config.colors.tab_bar and config.colors.tab_bar.background
	-- 配置（热）重载会重新求值：按旧调色板渲染的 tab 缓存必须作废，整行填色也要
	-- 重新从插件调色板取（light/dark 切换后 tab 端头才不会留着上一次主题的颜色）
	wezterm.on("window-resized", function(window)
		cols_cache[window:window_id()] = nil
	end)
	-- 渲染失败只报一次：这段在每个 tab 的重绘里都会跑，输入坏掉时会刷屏
	local render_failed = false
	wezterm.on("format-tab-title", function(tab, tabs, panes, _, hover, _)
		-- 顺手缓存各 pane 的前台进程名（wezterm 为标签栏已经算好的那份），
		-- 供 keybindings/keys.lua 判断是否在 zellij 里用，避免每次按键查 /proc
		pane_proc_cache.update(panes, tab.active_pane)
		if not tabline_ok() then
			return nil -- tabline 尚未 setup（启动瞬间），回退默认标题
		end
		local cols = window_cols(tab.window_id)
		if not cols then
			return render_tab(tab, hover) -- 拿不到窗口宽度，不折叠
		end

		local st = M.window_state[tab.window_id] or {}
		-- 左右状态栏优先用 update-status 实测的宽度；尚未测到时回退固定预留
		local left_w = st.left_w
		if not left_w then
			local ws = wezterm.mux.get_active_workspace():gsub("^.*[/\\]", "")
			left_w = M.reserve_left + wezterm.column_width(ws) + M.reserve_margin
		end
		local right_w = (st.right_w or M.reserve_right) + 1 -- +1 防实测欠账导致标签被裁

		-- 最坏情况指示器宽度：其余标签全部隐藏、两侧都挂指示器。
		-- 只用于右状态显隐与极端窄判定；标签预算用的是下方实际指示器宽度
		local worst_ind = 0
		if #tabs > 1 then
			worst_ind = wezterm.column_width(left_indicator(#tabs - 1))
				+ wezterm.column_width(right_indicator(#tabs - 1))
		end

		-- 右状态显隐：按实测宽度预留后活动标签连 min_active 都分不到，
		-- 即右状态"确实无法显示"——整段隐藏，把空间还给标签区。
		-- 带回差：恢复显示需要 unhide_margin 的额外余量，
		-- 避免 cpu 百分比等宽度微变在边界上每秒翻转显隐（频闪）
		local avail_shown = cols - left_w - right_w - M.gap
		local over = avail_shown - worst_ind - M.min_active
		local hide_right
		if st.hide_right then
			hide_right = over < M.unhide_margin
		else
			hide_right = over < 0
		end
		-- 右状态隐藏后无需分隔间隙，标签区填满至窗口右缘
		local avail = hide_right and (cols - left_w) or avail_shown
		st.hide_right = hide_right
		M.window_state[tab.window_id] = st

		-- 极端窄：右状态让位后仍放不下活动标签 + 两侧指示器 → 标签整段隐藏，
		-- 空间留给左段（mode、workspace）。剥离期间 st.left_w 冻结为全量旧值，
		-- 因此恢复判定天然基于完整左宽；带回差防边界频闪
		local threshold = worst_ind + M.min_active
		local extreme
		if st.extreme then
			extreme = avail < threshold + M.unhide_margin
		else
			extreme = avail < threshold
		end
		if extreme then
			st.hide_right = true
			st.extreme = true
			return "" -- 标签区整段让位，连测宽渲染都省掉
		end
		st.extreme = false

		-- 所有标签标题宽度之和一旦超过 cols-(n-1)-3，wezterm 会把全部标签
		-- 挤压到平均宽度（retro tab bar 行为），因此单个标签的宽度上限必须
		-- 控制在该预算内；同时扣除左侧状态栏，避免超出窗口右缘被裁掉
		local cap = math.max(cols - left_w - (#tabs - 1) - 3, 8)

		local widths = {}
		local active = 1
		for i, t in ipairs(tabs) do
			local _, w = render_cached(t)
			widths[i] = math.min(w, cap)
			if t.is_active then
				active = i
			end
		end

		-- 两段式预算：先按原始宽度布局一次拿到实际的两侧隐藏数，
		-- 再按实际指示器宽度（而非最坏值）压缩活动标签并重排；
		-- 指示器优先级最高，活动标签内容先截断，指示器永不截断
		local visible, hidden_left, hidden_right, leftmost, rightmost = M._layout(widths, active, avail)
		local ind = 0
		if hidden_left > 0 then
			ind = ind + wezterm.column_width(left_indicator(hidden_left))
		end
		if hidden_right > 0 then
			ind = ind + wezterm.column_width(right_indicator(hidden_right))
		end
		local fitted = M._fit(widths, active, avail, ind)
		if fitted ~= widths then
			widths = fitted
			visible, hidden_left, hidden_right, leftmost, rightmost = M._layout(widths, active, avail)
		end

		if M.debug then
			wezterm.log_info(
				string.format(
					"tab_collapse: idx=%d active=%s cols=%d avail=%d hide_right=%s widths=[%s] act=%d hidden=-%d/+%d leftmost=%d rightmost=%d",
					tab.tab_index + 1,
					tostring(tab.is_active),
					cols,
					avail,
					tostring(hide_right),
					table.concat(widths, ","),
					active,
					hidden_left,
					hidden_right,
					leftmost,
					rightmost
				)
			)
		end

		local idx = tab.tab_index + 1
		if not visible[idx] then
			return ""
		end

		local ok, result = pcall(function()
			-- 当前标签优先复用测宽时的缓存渲染（hover 只影响非活跃标签配色，
			-- 活跃标签或悬停非活跃标签签名不变时可直接复用）
			local items
			local c = tab.tab_id and render_cache[tab.tab_id]
			if c and c.sig == tab_signature(tab) and (tab.is_active or not hover) then
				items = c.items
			else
				items = render_tab(tab, hover)
			end
			if type(items) == "string" then
				items = { { Text = items } }
			else
				local copy = {}
				for i, v in ipairs(items or {}) do
					copy[i] = v
				end
				items = copy
			end

			-- 先把标签内容截断到预算（不含指示器），再挂指示器：
			-- 指示器宽度已在 _fit/_layout 中预留，保证完整显示
			if items_width(items) > widths[idx] then
				items = truncate_items(items, widths[idx])
			end

			local colors = adapter.colors()
			if hidden_left > 0 and idx == leftmost then
				local ind_fg, ind_bg = indicator_colors(colors)
				table.insert(items, 1, { Text = left_indicator(hidden_left) })
				table.insert(items, 1, ind_bg)
				table.insert(items, 1, ind_fg)
			end
			if hidden_right > 0 and idx == rightmost then
				local ind_fg, ind_bg = indicator_colors(colors)
				table.insert(items, ind_fg)
				table.insert(items, ind_bg)
				table.insert(items, { Text = right_indicator(hidden_right) })
			end
			return items
		end)
		if not ok then
			if not render_failed then
				render_failed = true
				wezterm.log_warn(
					"tab_collapse: render failed for tab " .. idx .. "（后续同样错误不再重复报告）: " .. tostring(result)
				)
			end
			-- 回退也要护住：render_tab 再抛一次就会把异常抛回 wezterm 的重绘路径，
			-- 那一层只会往日志写一行，界面上表现为标题乱掉。宁可给出 nil（用默认标题）。
			local ok2, fallback = pcall(truncate_items, render_tab(tab, hover), widths[idx])
			result = ok2 and fallback or nil
		end
		return result
	end)
end

-- cond 判据：读 M.window_state（format-tab-title 与 update-status 共同维护）。
-- 注意 cond 的语义是"要不要渲染这个组件"，所以这里必须是**可见**判据（不是"该不该隐藏"）。
-- 拿不到窗口 id（插件测宽用的代理对象等异常情况）时按"显示"处理，宁可多显示也不要误藏。
local function window_state_of(window)
	local ok, id = pcall(function()
		return window and window:window_id()
	end)
	if not ok or not id then
		return nil
	end
	return M.window_state[id]
end

local function right_status_visible(window)
	local st = window_state_of(window)
	return st == nil or st.hide_right ~= true
end

local function workspace_visible(window)
	local st = window_state_of(window)
	return st == nil or st.ws_stripped ~= true
end

-- 右状态整段显隐 / 极端窄下 workspace 剥离：统一用"给 section 组件挂 per-window
-- cond"落实（adapter.guard_section）。必须注册在 tabline.setup() 之后。
--
-- 为什么不再用 window:set_right_status("")：tabline 每个 update-status 都会重设一次
-- 右状态，我们再清空一次就是每 tick 的"填满→清空"打架，界面上就是频闪；而直接掏空
-- section 也不行——sections 是插件全局共享表，掏了会连带把别的窗口的右状态一起藏掉
-- （旧实现因此只能在单窗口时掏，多窗口时退化成逐 tick 清空）。cond 由插件在渲染时
-- 用当前 window 求值，于是每个窗口各判各的：既不打架，也不跨窗口串扰，隐藏时
-- tabline 自己就渲染出空串。
-- cond 读到的是上一 tick 的结论（状态由 format-tab-title 与下面的 handler 共同维护），
-- 最多差一个状态更新周期。隐藏期间保留上次实测的 right_w，供 format-tab-title 判定恢复。
--
-- 注意 config 必须显式传进来：M.apply 的 config 是那个函数的局部变量，这里拿不到；
-- 写成 config.colors 会解析成全局 config（nil），一进"切换底色"分支就抛异常——
-- 而 handler 抛异常时 wezterm 只会写日志、界面表现为"底色的动态调整没了"。
local guarded_sections
local guard_failed = false

-- 给一个 section 挂 cond；返回 true 表示该 section 已全部挂上（不存在/为空也算）
local function guard_section(name, visible)
	local guarded, total = adapter.guard_section(name, visible)
	if guarded == nil then
		return true
	end
	if guarded < total then
		wezterm.log_warn(string.format("tab_collapse: %s 有 %d/%d 个组件挂不上 cond", name, total - guarded, total))
	end
	return guarded > 0
end

-- cond 安装入口：update-status 每个周期调用（幂等），离屏测试也可以直接调。
-- 返回 false 表示插件侧不支持 cond，此时右状态不再自动让位。
function M.install_right_status_guards()
	local sections = adapter.sections()
	if not sections then
		return false
	end
	if sections == guarded_sections then
		return true
	end
	if guard_failed then
		return false
	end
	-- tabline 热重载会重建 sections 表，此时需要重新挂
	local ok = guard_section("tabline_x", right_status_visible)
		and guard_section("tabline_y", right_status_visible)
		and guard_section("tabline_z", right_status_visible)
		and guard_section("tabline_b", workspace_visible)
	if not ok then
		wezterm.log_warn("tab_collapse: 右状态段挂不上 cond，右状态将不再自动让位（不再重试）")
		guard_failed = true
		return false
	end
	guarded_sections = sections
	return true
end

function M.apply_right_status_control(config)
	local tick_failed = false

	local function tick(window)
		local id = window:window_id()
		cols_cache[id] = nil -- 周期失效列数缓存，覆盖字体缩放等不触发 window-resized 的变化
		local st = M.window_state[id] or {}
		M.window_state[id] = st

		-- 顺带清理已关闭标签的渲染缓存
		local ok3, all = pcall(wezterm.mux.all_windows)
		if ok3 then
			local live = {}
			for _, mw in ipairs(all) do
				for _, t in ipairs(mw:tabs()) do
					live[t:tab_id()] = true
				end
			end
			for tab_id in pairs(render_cache) do
				if not live[tab_id] then
					render_cache[tab_id] = nil
				end
			end
		end

		local left_w, right_w = measure_status_widths(window)
		if left_w and not st.ws_stripped then -- workspace 剥离期间冻结全量左宽，供恢复判定
			st.left_w = left_w
		end
		-- 右状态隐藏期间 cond 会把右段渲染成空串（实测宽度 0），此时不覆盖上次的值，
		-- 供 format-tab-title 判定何时恢复；恢复后重新实测
		if right_w then
			st.right_w = right_w
		end

		if not M.install_right_status_guards() then
			return
		end

		-- 极端窄：标签区已整段让位，左段保持完整（mode + workspace 等）。
		-- workspace 仅在窗口物理宽度连完整左段都放不下时才掏空（"确实无法显示
		-- 才消失"）；带回差防边界频闪
		if st.extreme then
			local cols = window_cols(id)
			if st.ws_stripped then
				if cols and st.left_full and cols >= st.left_full + M.unhide_margin then
					st.ws_stripped = false
				end
			else
				if left_w then
					st.left_full = left_w
				end
				if cols and st.left_full and cols < st.left_full then
					st.ws_stripped = true
				end
			end
		elseif st.ws_stripped then
			st.ws_stripped = false
		end

		-- bar 底色：右状态隐藏时整行填实（右侧不留透明空洞），
		-- 显示时恢复 config 里的默认底色（appearance.lua，默认透明）。
		-- 走共享 helper 只改自己的键，避免和 dynamic_ui 的 scrollbar_thumb 互相打回
		local bg = resolve_bar_bg()
		local overrides = window:get_config_overrides() or {}
		local cur = overrides.colors and overrides.colors.tab_bar and overrides.colors.tab_bar.background
		local want = st.hide_right and bg or config_bar_bg
		if cur ~= want then -- 避免每秒一次的 override 应用触发整窗重绘
			config_overrides.update_colors(window, overrides, config.colors, function(_, colors)
				colors.tab_bar = colors.tab_bar or {}
				colors.tab_bar.background = want
			end)
		end
	end

	-- 这个 handler 每秒跑一次；抛异常时 wezterm 只往日志里写一行、界面上就是"动态调整
	-- 不生效"，很难发现。所以自己兜一层，并把错误喊出来（只喊一次，避免每秒刷屏）。
	wezterm.on("update-status", function(window)
		local ok, err = pcall(tick, window)
		if not ok and not tick_failed then
			tick_failed = true
			wezterm.log_error("tab_collapse: update-status 出错（后续同样错误不再重复报告）: " .. tostring(err))
		end
	end)
end

return M
