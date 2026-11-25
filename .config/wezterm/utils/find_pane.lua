-- Leader+f 的跨 pane 搜索：候选 + 预览文本都用 Lua 从原生 API 取，界面 / 跳转交给 fzf。
--
-- 覆盖范围：所有窗口的所有 tab / pane（wezterm.mux.all_windows() → w:tabs() → t:panes()）。
-- 跳转不用 `wezterm cli activate-pane`（wezterm 没有「activate by pane_id」的 Lua action），
-- 而是 act.ActivateWindow + ActivateTab + ActivatePaneByIndex 组合，
-- 所以候选 id 里编码了 "<win_idx>.<tab_idx>.<pane_idx>|pane_id#行号"。
--
-- 能做：跨 tab/pane 模糊搜索 + 跳转、装饰行过滤、ANSI 颜色、预览定位到选中行。
-- 做不到：真正内嵌的 overlay 预览（wezterm 没给 Lua 提供 overlay 渲染 API），只能开临时 pane 跑 fzf。
-- M.action_for 是同一套候选的 InputSelector 版本（无预览），保留作对照，不绑键。
-- 排查：需要时把 M.debug 打开，会往 $TMPDIR/wezterm-find-pane-debug.txt 写候选数与每个 pane 的行数/维度。

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- 不设上限：每个 pane 取它的**全部历史**（行数来自 pane:get_dimensions().scrollback_rows），
-- 候选也不截断。代价是超长 scrollback 的 pane 会让候选条数变多（fzf 仍能毫秒级处理）。
M.include_scrollback = true  -- 默认连历史一起搜
M.color = true               -- 保留 ANSI（fzf 用 --ansi 解析；CLI 加 --escapes）
M.min_arrows_for_chrome = 2 -- 回退路径里：≥2 个 powerline 箭头才当作提示符/状态栏丢弃（可调高/调低）
M.debug = false              -- 打开才写 $TMPDIR/wezterm-find-pane-debug.txt（排查用，平时不落盘）
-- 临时候选/预览文件的兜底清理年龄（秒），见 cleanup_stale_temp_files
M.temp_ttl = 600

-- 临时文件（候选表 + 每个 pane 的预览文本）正常由 fzf 的 enter/esc bind 删掉；
-- 但 fzf 所在 pane 被外部杀掉、或 wezterm 直接退出时 bind 不会跑，文件会留在 /tmp。
-- 两道兜底：
--   1) sh 侧 trap EXIT/INT/TERM —— Ctrl+C、pane 被正常关闭（SIGTERM）都能兜住；
--   2) 文件名自带创建时间（wezterm-find-pane-<epoch>-<rand>），下次调用前清掉超过
--      M.temp_ttl 的旧文件 —— 只认这个前缀 + 时间戳，绝不碰别的程序的临时文件；
--      正在使用中的（本轮、以及 TTL 内并发开的）因为"没超时"不会被清。
-- 临时目录。**从源头把关**，而不是在拼接点写引用：base 会拼进生成的 shell 脚本，其中
-- fzf 的 --preview/--bind 还会被 fzf 自己再跑一层 shell，两层嵌套引用很难写对。所以路径
-- 一旦含空白 / 引号 / 变量展开 / glob 字符就回退到 /tmp —— 宁可换目录，也不要拼出一句
-- 会静默失效的 shell（`rm -f /a b/x` 会删到别的路径且不报错）。
local UNSAFE_PATH = "[%s'\"`$\\;|&<>()*?%[%]{}!#~]"

---把候选临时目录解析成一个"能安全拼进 shell 脚本"的路径。
---不传参时读 $TMPDIR（生产路径）；传参是为了测试。
---@param candidate string|nil
---@return string
function M.temp_dir(candidate)
	local d = candidate or os.getenv("TMPDIR")
	if type(d) == "string" and d:sub(1, 1) == "/" and not d:find(UNSAFE_PATH) then
		return d
	end
	return "/tmp"
end

local function new_temp_base()
	return string.format("%s/wezterm-find-pane-%d-%06d", M.temp_dir(), os.time(), math.random(0, 999999))
end

-- 返回清掉的个数；拿不到 glob / 目录不可读时静默跳过，不影响主流程
function M.cleanup_stale_temp_files()
	local dir = M.temp_dir()
	local ok, entries = pcall(wezterm.glob, "wezterm-find-pane-*", dir)
	if not ok or type(entries) ~= "table" then
		return 0
	end
	local now, removed = os.time(), 0
	for _, entry in ipairs(entries) do
		local stamp = entry:match("wezterm%-find%-pane%-(%d+)%-")
		if stamp and now - tonumber(stamp) > M.temp_ttl then
			-- wezterm.glob 返回相对 dir 的名字；万一是绝对路径也照删
			local full = entry:sub(1, 1) == "/" and entry or (dir .. "/" .. entry)
			if os.remove(full) then
				removed = removed + 1
			end
		end
	end
	return removed
end

local function notify(window, msg)
	pcall(function()
		window:toast_notification("find pane", msg, 3000)
	end)
end

local function pane_id(pane)
	local ok, id = pcall(function()
		return tostring(pane:pane_id())
	end)
	return ok and id or "?"
end

local function pane_title(pane)
	local ok, t = pcall(function()
		return (pane:get_title() or ""):gsub("\t", " ")
	end)
	return ok and t or ""
end

-- 候选前缀用房内**前台进程的 basename**（zsh / nvim / yazi …），而不是 pane 标题：
-- 标题是"当前 cwd"，而候选是整段历史（含 cd 之前的行），贴在一起就会张冠李戴。
-- 数据来源：先用标签栏那套缓存（wezterm 画 tab 标题时本就算好，零开销；`utils/pane_proc_cache.lua`），
-- 缓存里没有这个 pane 才调 `pane:get_foreground_process_name()`（官方 API 给的是可执行文件**路径**，
-- 远程/复用器 pane 可能拿不到 → 那时退回 pane 标题）。
-- 为什么不再看缓存的"新鲜度"：缓存只在标签栏重绘时更新，而没重绘本身就说明该 pane 没有输出，
-- 前台进程几乎不可能变；真变了也会立刻产生输出并刷新缓存。所以有记录就直接信，省掉 idle 时的 /proc 查询。
local proc_cache = nil
do
	local ok, mod = pcall(require, "utils.pane_proc_cache")
	if ok then
		proc_cache = mod
	end
end

-- 官方文档给的 basename 写法（同时处理 / 和 \）
local function basename(path)
	return (path:gsub("(.*[/\\])(.*)", "%2"))
end

local function pane_prefix(pane, pid, title)
	local entry = proc_cache and proc_cache.get(pid)
	if entry and entry.name then
		local base = basename(entry.name)
		if base ~= "" then
			return base
		end
	end
	local ok, path = pcall(function()
		return pane:get_foreground_process_name()
	end)
	if ok and type(path) == "string" and path ~= "" then
		local base = basename(path)
		if base ~= "" then
			return base
		end
	end
	return title
end

-- UI 装饰行（zellij/wezterm 的 powerline 状态栏、tab 条）不该进候选：
-- ≥2 个 powerline 箭头（\uE0B0-\uE0B3），或私有使用区/box drawing 字形占比 ≥1/3 → 丢弃。
local function is_chrome_line(line)
	-- 装饰字形都在 U+2500 以上，纯 ASCII 行直接否定，省掉逐字符扫描（shell 输出绝大多数是 ASCII）
	if not line:find("[\128-\255]") then
		return false
	end
	local glyphs, arrows, total = 0, 0, 0
	local need = M.min_arrows_for_chrome
	for _, cp in utf8.codes(line) do
		total = total + 1
		if cp >= 0xE0B0 and cp <= 0xE0B3 then
			arrows = arrows + 1
			-- 够阈值就能确定是装饰行，后面不用再扫（提示符行往往是长行）
			if arrows >= need then
				return true
			end
		end
		if (cp >= 0xE000 and cp <= 0xF8FF) or (cp >= 0x2500 and cp <= 0x259F) then
			glyphs = glyphs + 1
		end
	end
	return total > 0 and glyphs * 3 >= total
end

-- 按**物理行**遍历（空行也算一行），边匹配边交给 fn，不建中间数组。
-- 不能用 `gmatch("[^\r\n]+")`：它会跳过空行，"第几行"就成了"第几个非空行"，和预览的行号错位。
-- 行尾的换行不额外算一行（与旧实现一致）。
local function each_line(text, fn)
	if not text or text == "" then
		return 0
	end
	if text:sub(-1) == "\n" then
		text = text:sub(1, -2)
	end
	local no = 0
	for line in (text .. "\n"):gmatch("(.-)\n") do
		no = no + 1
		fn(line, no)
	end
	return no
end

-- 取 pane 文本（Lua 原生 API，不起进程）。
-- 行数：`get_lines_as_text([nlines])` / `get_lines_as_escapes([nlines])` 的可选参数默认是"可见区"，
-- 传 scrollback_rows + viewport_rows 覆盖 [scrollback_top, 视口底部)——即整屏 + 全部历史
-- （CLI 的 `--start-line -999999` 也是这个区间，只传 scrollback_rows 会漏掉最老一屏）。
local function lua_text(pane, want_scroll)
	local nlines, dims = nil, nil
	local ok_d, d = pcall(function()
		return pane:get_dimensions()
	end)
	if ok_d then
		dims = d
		local viewport = tonumber(d and d.viewport_rows) or 0
		local scroll = tonumber(d and d.scrollback_rows) or 0
		if want_scroll then
			nlines = scroll + viewport
		elseif viewport > 0 then
			nlines = viewport
		end
	end
	local methods = M.color and { "get_lines_as_escapes", "get_lines_as_text", "get_logical_lines_as_text" }
		or { "get_lines_as_text", "get_logical_lines_as_text" }
	for _, method in ipairs(methods) do
		if type(pane[method]) == "function" then
			-- 注意 nlines 为 nil 时不要传参数（`f(pane, nil)` 与 `f(pane)` 对实现可能不同）
			local ok, text
			if nlines then
				ok, text = pcall(pane[method], pane, nlines)
			else
				ok, text = pcall(pane[method], pane)
			end
			if ok and type(text) == "string" and text ~= "" then
				return (text:gsub("\r", "")), dims
			end
		end
	end
	return "", dims
end

-- 备用通道：`wezterm cli get-text`（mux 协议）。默认关闭——它只在 Lua 侧明显取不全时才有意义
-- （例如后台 tab 的 pane 在被渲染过一次之前，Lua 侧可能拿不到文本；切一次 tab 就好，属于 wezterm 行为）。
-- 打开后：拿到的文本会同时用于候选和预览，所以行号依然自洽。
M.cli_fallback = false

---@param pid integer|string
---@param want_scroll boolean|nil
---@return string 取不到就返回 ""
function M.cli_text(pid, want_scroll)
	local args = { "wezterm", "cli", "get-text", "--pane-id", tostring(pid) }
	if want_scroll then
		args[#args + 1] = "--start-line"
		args[#args + 1] = "-999999"
	end
	if M.color then
		args[#args + 1] = "--escapes"
	end
	-- run_child_process 返回 (success, stdout, stderr)，而 pcall 会在最前面再插一个 true，
	-- 所以要接三个值。只接两个的话 out 拿到的是那个 boolean，`type(out)=="string"` 恒不成立
	-- → 这个函数永远返回 ""，CLI 兜底整个失效（还白起一个同步子进程）。
	local ok, success, out = pcall(wezterm.run_child_process, args)
	if ok and success and type(out) == "string" then
		return (out:gsub("\r", ""))
	end
	return ""
end

-- 数物理行：gsub 在 C 里数换行，不建数组（只有开 CLI 兜底 / 调试时才需要它）
local function count_lines(text)
	if not text or text == "" then
		return 0
	end
	local n = select(2, text:gsub("\n", "")) + 1
	if text:sub(-1) == "\n" then
		n = n - 1
	end
	return n
end

-- 返回：文本, 诊断信息。文本同时喂给候选和预览，保证"行号所在文本" == "预览读的文本"。
local function pane_text(pane, pid, want_scroll)
	if want_scroll == nil then
		want_scroll = M.include_scrollback
	end
	local text, dims = lua_text(pane, want_scroll)
	local info = {
		cli = -1,
		via = "lua",
		lua = 0, -- 行数由后面的扫描给出；开 CLI 兜底/调试时这里先数一次（决定要不要兜底）
		viewport = tonumber(dims and dims.viewport_rows) or 0,
		scrollback = tonumber(dims and dims.scrollback_rows) or 0,
		top = tonumber(dims and dims.physical_top) or 0,
	}
	if M.cli_fallback or M.debug then
		info.lua = count_lines(text)
	end
	if M.cli_fallback and pid and info.lua < math.max(1, info.viewport) then
		local alt = M.cli_text(pid, want_scroll)
		info.cli = count_lines(alt)
		if info.cli > info.lua then
			text, info.via = alt, "cli"
		else
			info.via = info.lua > 0 and "lua" or "none"
		end
	end
	return text, info
end

-- 扫一个 pane 的文本，把候选喂给 sink(pid, key, 行号, 行内容, 前缀)，返回 (文本行数, 候选数)。
-- 行号 = 该 pane 文本里的**物理行号**：空行/装饰行照样递增，只是它们不进候选；
-- 预览读的就是这份文本，所以行号与预览必然是同一个坐标系。
-- 为什么不走 OSC 133 语义区：语义区那段文本和整屏不是同一份，行号对不上。
local function scan_pane(text, key, pid, prefix, sink)
	local n = 0
	local lines = each_line(text, function(line, no)
		if line:find("%S") and not is_chrome_line(line) then
			n = n + 1
			sink(pid, key, no, line, prefix)
		end
	end)
	return lines, n
end

-- 枚举所有窗口/tab/pane（window 对象没有 panes()，必须走 tab: w:tabs() → t:panes()），
-- 逐 pane 把候选喂给 sink；返回 previews(pid → 原文) 和 report(诊断)。
--   sink(pid, key, 行号, 行内容, 前缀)：行内容为 nil 表示这个 pane 一个候选都没有
--   前缀 = 前台进程 basename（拿不到时退回 pane 标题），见 pane_prefix
--   key 形如 "win.tab.pane|pane_id"，跳转用它（纯 Lua action，不需要 mux CLI）
local function collect(sink, want_scroll)
	local previews, seen = {}, {}
	local report = { windows = 0, tabs = 0, panes = 0, empty = 0, detail = {} }

	local function scan(tab, tab_idx, win_idx)
		local ok, list = pcall(function()
			return tab:panes()
		end)
		if not ok or not list then
			return
		end
		report.tabs = report.tabs + 1
		for pane_idx, p in ipairs(list) do
			local id, title = pane_id(p), pane_title(p)
			-- 只对有效 id 去重；取不到 id 的 pane 不能互相顶掉
			local unique = id == "?" or not seen[id]
			if id ~= "?" then
				seen[id] = true
			end
			if unique then
				-- id 编码成 "win_idx.tab_idx.pane_idx|pane_id"：跳转用索引（纯 Lua action，不需要 mux CLI）
				local key = string.format("%d.%d.%d|%s", win_idx or 0, tab_idx, pane_idx - 1, id)
				local prefix = pane_prefix(p, id, title)
				local text, info = pane_text(p, tonumber(id), want_scroll)
				local lines, n = scan_pane(text, key, id, prefix, sink)
				info.lua = lines
				report.panes = report.panes + 1
				if M.debug then
					report.detail[#report.detail + 1] = {
						id = id, prefix = prefix, title = title, win = win_idx or 0, tab = tab_idx,
						idx = pane_idx - 1, n = n, info = info,
					}
				end
				if text ~= "" then
					previews[id] = text
				else
					report.empty = report.empty + 1
				end
				if n == 0 then
					-- 取不到内容的 pane 也列出来（看得见才好排查）
					sink(id, key, 0, nil, prefix)
				end
			end
		end
	end

	-- 这里要的是**所有窗口**的所有 pane（跨 workspace 也要能跳），所以统一用 wezterm.mux 枚举。
	-- 旧注释写的理由是"keybinding 回调拿到的是 `Pane`，它没有 `:window()` / `:tab()`"——那是错的：
	-- 回调里的 pane 就是 `MuxPane`，两个方法都有（wezterm 把 action_callback 编译成 EmitEvent，
	-- tw_mod.rs 的事件分发以 `pane: MuxPane` 收参再 pack_multi 给 Lua；同一个配置里
	-- keybindings/keys.lua 就在按键回调里用 pane:window() / pane:tab()）。
	-- 枚举所有窗口是实现需要，不是因为拿不到当前 pane 的上下文。
	-- 索引 (win, tab, pane) 全部是 0-based，正好是 ActivateWindow / ActivateTab / ActivatePaneByIndex 需要的值。
	local ok_all, all = pcall(function()
		return wezterm.mux.all_windows()
	end)
	if ok_all and all then
		for wi, w in ipairs(all) do
			report.windows = report.windows + 1
			local ok_tabs, tabs = pcall(function()
				return w:tabs()
			end)
			if ok_tabs and tabs then
				for ti, t in ipairs(tabs) do
					scan(t, ti - 1, wi - 1)
				end
			end
		end
	end

	return previews, report
end

-- 跳转：纯 Lua（不再调 mux CLI）。id 形如 "<tab_idx>.<pane_idx>|pane_id#<行号>" ——
-- wezterm 没有「activate by pane_id」的 Lua action，所以用 ActivateTab + ActivatePaneByIndex 组合。
local function jump(window, pane, id)
	local win_idx, tab_idx, pane_idx = tostring(id or ""):match("^(%d+)%.(%d+)%.(%d+)")
	if not win_idx then
		return
	end
	window:perform_action(act.ActivateWindow(tonumber(win_idx)), pane)
	window:perform_action(act.ActivateTab(tonumber(tab_idx)), pane)
	window:perform_action(act.ActivatePaneByIndex(tonumber(pane_idx)), pane)
end

function M.action_for(window, pane)
	local ok, action, err = pcall(function()
		-- InputSelector 只能吃 {id, label} 列表，所以这里用 sink 攒成表（无预览的对照实现，不绑键）
		local entries = {}
		collect(function(id, key, no, line, prefix)
			if line then
				entries[#entries + 1] = { id = key .. "#" .. no, label = prefix .. "  " .. line }
			else
				entries[#entries + 1] = { id = key .. "#0", label = prefix .. "  ⚠ 取不到文本" }
			end
		end, M.include_scrollback)
		if #entries == 0 then
			return nil, "没有可用 pane"
		end
		return act.InputSelector({
			title = "跳到 pane（输入即搜）",
			fuzzy = true,
			choices = entries,
			action = wezterm.action_callback(function(window, pane, ...)
				local n = select("#", ...)
				for i = 1, n do
					local v = select(i, ...)
					if type(v) == "table" and v.id then -- 整条目回传
						jump(window, pane, v.id)
						return
					end
				end
				for i = 1, n do
					local v = select(i, ...)
					if type(v) == "string" then
						local id = v:match("^(%d+%.%d+%.%d+)")
						if id then
							jump(window, pane, id)
							return
						end
					end
				end
				notify(window, "没拿到选中项")
			end),
		})
	end)
	if not ok then
		notify(window, tostring(action))
		return nil
	end
	if action == nil then
		notify(window, err or "没有可用 pane")
		return nil
	end
	return action
end

-- ── 用 fzf 当「屏显工具」的版本（Leader+f）────────────────────────────────────
-- 分工：**候选和预览文本都由 Lua 用原生 API 收集**（不逐 pane 起 `wezterm cli get-text`），
--       界面 / 跳转交给 fzf。两个已确认的约束：
--   1) SplitPane 的参数只有 command/args/direction，**不能重定向 stdin**，
--      所以必须有一层 `sh -c` 把候选文件喂给 fzf（这是唯一用 sh 的地方）；
--   2) fzf 的 --preview / --bind 里的命令由 fzf 自己经 shell 执行（fzf 的实现如此）。
-- 想要「彻底零 shell」只能用 M.action_for（InputSelector），代价是没有预览。
function M.fzf_action_for(window, pane, opts)
	opts = opts or {}
	M.cleanup_stale_temp_files() -- 顺手清掉上一轮异常退出留下的文件（见 temp_ttl）
	local base = new_temp_base()
	local path = base .. ".cand"
	local f, err = io.open(path, "w")
	if not f then
		return nil, "无法写临时文件: " .. tostring(err)
	end
	-- 边扫边写：候选可能上万条，不先攒成 table 再序列化一遍。
	-- 每行 "<pane_id>\t<label>\t<行号>"：{1} 预览/跳转、{2} 显示和搜索、{3} 让预览定位到选中行。
	-- （行内容为 nil 表示该 pane 一个候选都没有 → 只给一条标题占位行，行号写 1）
	-- 注意：fzf 会把命令行里的占位符替换成**单引号包起来的字符串**（"Each expression expands to a
	-- quoted string"），所以 `$(( {3} + 20 ))` 这种算术一定报错；行号只在 --preview-window 里以
	-- 裸字段表达式的形式用（fzf 自己解析），不进 shell 算术。
	local n_entries, write_err = 0, nil
	local ok_collect, previews, report = pcall(collect, function(pid, _, no, line, prefix)
		n_entries = n_entries + 1
		-- f:write 失败返回 nil + 原因；不接返回值的话，磁盘写满会静默产出一份被截断的候选列表
		local wok, werr
		if line then
			-- 行内容里的 Tab 必须转掉：候选格式是 Tab 分隔的 3 字段，行内 Tab 会把行号挤到
			-- 第 4+ 字段（{3} 拿到垃圾值 → 预览定位失效），--with-nth=2 也只显示到第一个
			-- Tab 为止（显示截断 + Tab 之后的文本搜不到）。只转候选这一份，预览原文不动。
			wok, werr = f:write(pid, "\t", prefix, "  ", (line:gsub("\t", " ")), "\t", no, "\n")
		else
			wok, werr = f:write(pid, "\t", prefix, "  ⚠ 取不到文本\t1\n")
		end
		if not wok and not write_err then
			write_err = werr -- 只记第一次：真写不进去时后面每条都会失败，刷屏没意义
		end
	end, opts.scrollback)
	f:close()
	-- collect 中途抛错时，原本走不到上面的 f:close() → fd 泄漏 + 临时文件残留
	if not ok_collect then
		os.remove(path)
		return nil, "收集候选失败: " .. tostring(previews)
	end
	if write_err then
		os.remove(path)
		return nil, "候选写入失败: " .. tostring(write_err)
	end
	if n_entries == 0 then
		os.remove(path)
		return nil, "没有可用 pane"
	end
	-- 每个 pane 的原文单独落盘：预览直接 head 这个文件，行号与候选严格同一份文本
	-- （不再让预览走另一条通道去取文本，从根上排除"行对不上"）
	for pid, text in pairs(previews) do
		local pf = io.open(string.format("%s.%s.txt", base, pid), "w")
		if pf then
			pf:write(text)
			pf:close()
		end
	end
	local script = table.concat({
		-- 兜底清理：fzf 退出（含被 Ctrl+C / SIGTERM）时删掉本轮临时文件。
		-- 不能用 `exec fzf`——exec 会替换掉 shell，EXIT/INT/TERM trap 就不会执行了。
		"trap 'rm -f " .. base .. " " .. base .. ".*' EXIT INT TERM;",
		"fzf",
		"--delimiter='\\t'",
		-- 注意：fzf 的 --nth 作用在 --with-nth **之后**的列上，
		-- 所以 --with-nth=2 之后只剩 1 列，这里必须写 --nth=1（写 2 会指向不存在的列 → 输入搜不出）。
		-- 不加 --no-sort：交给 fzf 按匹配质量排序（匹配得越完整越靠前），与脚本版一致。
		"--with-nth=2 --nth=1",
		-- fzf 的默认截断标记是 `··`（`--ellipsis` 默认值），长行末尾那两个点就是它，去掉
		"--ellipsis=''",
		-- fzf ≥0.61 默认会**横向滚动**长行把匹配词露出来，滚动会把行首的进程名前缀切掉
		-- （"关键词在中间 → 前缀消失"）。关掉横向滚动：长行一律右侧截断，前缀始终可见；
		-- 匹配词本身看不见没关系，右侧预览里有完整上下文。
		"--no-hscroll",
		(M.color and "--ansi" or ""),
		"--header='回车跳转 · 输入即搜（候选由 Lua 收集）'",
		-- 预览读的正是采集时落盘的那份文本（候选和预览同源，行号才对得上）。
		"--preview='cat " .. base .. ".{1}.txt'",
		-- 关键：fzf 的预览输出默认**顶部对齐**，预览区只有十几行时，选中行会落在可见区之外
		-- （于是只能看到它上面的内容，看起来就是"对不上"）。`+{3}/2` 是手册里
		-- "matching line in the middle of the window" 的写法：{3} = 选中行号，/2 = 放在预览区中间。
		"--preview-window='right:55%,+{3}/2'",
		-- 回车 = 跳转 + 把目标 pane 视口滚到匹配行。不再用 `wezterm cli activate-pane` 跳转：
		-- 视口滚动是 GUI 内部状态，wezterm cli 没有 scroll 子命令，外部进程够不着。
		-- 改成把 "<pane_id>:<行号>"（base64）用 OSC 1337 SetUserVar 写进 /dev/tty（= 本临时
		-- pane 的 pty），wezterm 解析后触发 user-var-changed 事件，由 M.on_user_var 在 GUI
		-- 里完成聚焦 + 滚动（wezterm 官方文档的同款写法）。{1}/{3} 由 fzf 替换成单引号
		-- 包裹的值；printf 格式串里的 \033/\007 是 OSC 的起止（ESC / BEL）。
		-- bind 里顺手删临时文件（正常路径立刻清掉，不等 trap）；base 本体已不存在，留着 -f 无副作用
		--
		-- base64 不带 -w0：`-w0` 是 GNU 专有（BSD/macOS 的 base64 没有这个选项，会直接报错
		-- → 回车跳转静默失效）。这里不加是对的，因为输入恒为 "<pane_id>:<行号>"（纯数字加冒号，
		-- 十几个字符），远不到 GNU 的 76 字符换行阈值，两边的 base64 都只输出一行。
		-- 若将来换更长的载荷，这里必须改成显式去换行的写法。
		"--bind='enter:execute-silent(printf \"\\033]1337;SetUserVar=find_pane=%s\\007\" \"$(printf %s {1}:{3} | base64)\" > /dev/tty)+execute-silent(rm -f " .. base
			.. " " .. base .. ".*)+execute-silent(wezterm cli kill-pane --pane-id $WEZTERM_PANE)+accept'",
		"--bind='esc:execute-silent(rm -f " .. base .. " " .. base
			.. ".*)+execute-silent(wezterm cli kill-pane --pane-id $WEZTERM_PANE)+abort'",
		"< '" .. path .. "'",
		-- 整条脚本必须拼成**一行**，用 `;` 隔开 trap 和 fzf：
		-- 纯空格且 trap 后无 `;` → fzf 及之后全部参数被 trap 当成信号名报错，fzf 不执行（pane 一闪而过）；
		-- 按换行拼 → fzf 独占一行裸跑（所有 flag 变成后续"命令未找到"），无预览、无 delimiter。
	}, " ")
	-- 诊断落盘（默认关，见 M.debug）：候选数 + 每个 pane 的 lua/cli 行数与维度 + 最终脚本
	if M.debug then
		local dbg = io.open(M.temp_dir() .. "/wezterm-find-pane-debug.txt", "w")
		if dbg then
			dbg:write(string.format(
				"scrollback=%s windows=%d tabs=%d panes=%d empty=%d entries=%d\n",
				tostring(opts.scrollback), report.windows, report.tabs, report.panes, report.empty, n_entries
			))
			dbg:write("tmpfile=", path, "\n")
			-- 每个 pane 一行：lua=文本行数(物理行) cli=CLI 兜底行数(-1 表示没走) via=实际用的通道
			-- lines=候选行数（几十 = 只有可见区；几百上千 = 含历史）
			-- prefix=候选前缀（前台进程 basename，取不到才退回标题） title=pane 标题（cwd）
			for _, d in ipairs(report.detail) do
				dbg:write(string.format(
					"pane %s win=%d tab=%d idx=%d lines=%d lua=%d cli=%d via=%s viewport=%d scrollback=%d top=%d prefix=%s title=%s\n",
					d.id, d.win, d.tab, d.idx, d.n, d.info.lua, d.info.cli, d.info.via,
					d.info.viewport, d.info.scrollback, d.info.top, d.prefix, d.title
				))
			end
			dbg:write("script=", script, "\n")
			dbg:close()
		end
	end
	return act.SplitPane({
		direction = "Down",
		size = { Percent = 40 },
		command = { args = { "sh", "-c", script } },
	})
end

-- ── user-var-changed：fzf 回车后的「跳转 + 滚到匹配行」────────────────────────
-- 通道：临时 pane 里的 sh 把 "<pane_id>:<行号>"（base64）用 OSC 1337 SetUserVar 写到
-- /dev/tty，wezterm 解析后触发本事件（value 已解码）。为什么不让 fzf 直接
-- `wezterm cli activate-pane`：视口滚动是 GUI 内部状态，cli 没有 scroll 子命令，
-- 外部进程够不着；activate + scroll 必须在 GUI 的 Lua 里做。
-- 滚动算法：ScrollToTop 把视口顶对齐 scrollback 顶（= 采集文本的第 1 行，采集覆盖
-- [scrollback_top, 屏底] 全量），再向下滚 no-1-半屏 行，匹配行正好落在视口正中。
-- 已知边界：采集之后若目标 pane 又有新输出，行号会向下漂移（预览不受影响，预览读的是落盘文本）；
-- alt-screen 的 pane（vim 等）没有 scrollback，滚动动作无效但无害。
function M.on_user_var(window, pane, name, value)
	if name ~= "find_pane" then
		return
	end
	local pid, no = tostring(value or ""):match("^(%d+):(%d+)$")
	if not pid then
		return
	end
	no = tonumber(no)
	local ok, err = pcall(function()
		for _, w in ipairs(wezterm.mux.all_windows()) do
			for ti, t in ipairs(w:tabs()) do
				for pi, p in ipairs(t:panes()) do
					if tostring(p:pane_id()) == pid then
						-- 激活目标窗口/tab/pane。不用 ActivateWindow(全局索引)从「当前窗口」上下文
						-- 去激活别的窗口——跨窗口时序不可靠；直接解析目标 mux 窗口对应的 GuiWindow，
						-- 在它自己的上下文里操作。
						local wid = w:window_id()
						local gw = wezterm.gui.gui_window_for_mux_window(wid)
						if not gw then
							-- 非活跃 workspace 的窗口解析不出 GuiWindow：退回 cli 激活，只是不滚动。
							-- 这一步在 GUI 线程上同步起子进程，但这条路径本来就很少走到，可以接受；
							-- 关键是**失败要说出来** —— 原来丢掉了 (success, stdout, stderr)，按了
							-- 回车什么都没发生，也查不到原因（和 cli_text 是同一类坑）。
							local ok_cli, success, _, stderr =
								pcall(wezterm.run_child_process, { "wezterm", "cli", "activate-pane", "--pane-id", pid })
							if not ok_cli or not success then
								local why = stderr and tostring(stderr):gsub("%s+$", "") or ""
								notify(
									window,
									"跳转失败：wezterm cli activate-pane 没能激活 pane "
										.. tostring(pid)
										.. (why ~= "" and ("（" .. why .. "）") or "")
								)
							end
							return
						end
						-- 聚焦目标窗口：GuiWindow 没有 activate() 方法（文档里 ActivateWindow 的
						-- "等价写法"已过时），改用 ActivateWindow action（全局第 n 个 GUI 窗口）。
						-- 不能用对象相等（g == gw）匹配——句柄每次调用都是新的 userdata，
						-- 恒等比较永远失败；按 mux window id 比对。
						local gw_idx
						for i, g in ipairs(wezterm.gui.gui_windows()) do
							local okm, mw = pcall(function()
								return g:mux_window()
							end)
							if okm and mw and mw:window_id() == wid then
								gw_idx = i - 1
								break
							end
						end
						window:perform_action(act.ActivateWindow(gw_idx or 0), pane)
						gw:perform_action(act.ActivateTab(ti - 1), p)
						gw:perform_action(act.ActivatePaneByIndex(pi - 1), p)
						gw:perform_action(act.ScrollToTop, p)
						local d = p:get_dimensions()
						local down = no - 1 - math.floor((tonumber(d.viewport_rows) or 0) / 2)
						if down > 0 then
							gw:perform_action(act.ScrollByLine(down), p)
						end
						return
					end
				end
			end
		end
	end)
	if not ok then
		notify(window, "跳转失败: " .. tostring(err))
	end
end

-- 订阅走 utils/user_var.lua（user-var-changed 的唯一注册点），不再自己 wezterm.on，
-- 也就去掉了原来那个 _G 标记——user_var.on 对同名订阅是覆盖，重复执行天然幂等。
--
-- 每次事件仍然重新 dofile 本文件：GUI 的文件监听只认 wezterm.lua（dofile 的文件改动
-- 不触发热重载），重新加载让处理器逻辑始终跟着文件走，不依赖重载时机。
-- user-var-changed 本身就是低频事件（pane 里程序主动发 SetUserVar 才触发）。
local user_var = require("utils.user_var")
user_var.on("find_pane", function(window, pane, value)
	local ok, mod = pcall(dofile, wezterm.config_dir .. "/utils/find_pane.lua")
	if ok and type(mod) == "table" and type(mod.on_user_var) == "function" then
		mod.on_user_var(window, pane, "find_pane", value)
	end
end)
user_var.install()

return M
