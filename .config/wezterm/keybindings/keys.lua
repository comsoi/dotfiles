-- 键位总表。语义速查 / 可视化见 docs/keymap.html（docs/keymap_check.mjs 会与本源核对）。
--
-- 两条与 wezterm 内部行为相关的约定（冲突排查时先看这里）：
--
--   * config.keys 是**赋值**（见文件末尾 M.apply）：整个键位表由本文件独占。
--     而 wezterm 构建键位映射时是顺序覆盖（config/src/config.rs 的
--     `tables.default.insert(...)`），**config.keys 里靠后的条目赢**。所以第三方插件
--     （比如 backend-wezterm 的 apply_to_config）如果也往 config.keys 里 insert，
--     谁后写谁生效 —— 想保留本文件的键位，就把它排在被注入者之后。
--
--   * **META / OPT 是 ALT 的别名，CMD / WIN 是 SUPER 的别名**，都不是独立修饰键。
--     实测于本机 wezterm 20261001-012714-20b645c1（把 META/OPT/ALT/CMD/WIN/SUPER 各绑一个
--     键，再 `wezterm --config-file <该探针> show-keys --lua` 看渲染结果：前三个都出
--     'ALT'，CMD/WIN/SUPER 都出 'SUPER'）。升级 wezterm 后值得复核一次。
--     上游插件常用 `modifiers = 'META'` 表示 Alt，写键位时别当成第五个修饰键。
local wezterm = require("wezterm")
local act = wezterm.action
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local M = {}

-- 锁定：把所有按键原样交给 pane 内程序（等价 zellij 的 Locked 模式）。
-- 进出都用 Leader+g。实现：用 config override 清空 keys，只在锁定时留一条 Leader+g 当解锁键；
-- 解锁时移除该 override，配置里的键位自动恢复（不缓存副本，改配置后依然生效）。
local function toggle_lock(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.keys ~= nil then
		overrides.keys = nil
		window:set_config_overrides(overrides)
		return
	end
	pcall(function()
		window:perform_action("PopKeyTable", pane) -- 退出可能正在激活的 key table
	end)
	overrides.keys = {
		{ key = "g", mods = "LEADER", action = wezterm.action_callback(toggle_lock) },
	}
	window:set_config_overrides(overrides)
end

-- 单个 wezterm tab 时，这几个键要原样透传进 pane 内的 tmux/zellij/nvim。
-- 必须用 kitty 键盘协议的原始 CSI-u 字节：act.SendKey 会把字母归一化成小写码位
-- （key = "t" 和 key = "T" 都试过，tmux/zellij 都收不到预期按键），
-- 而它们期待带 Shift 的大写码位（"T" = 84、"W" = 87）。
-- 格式：CSI <码位>;<1+修饰位>u，修饰位 Shift=1、Alt=2、Ctrl=4
local CSI_CTRL_SHIFT_T = "\x1b[84;6u" -- Ctrl+Shift+T（6 = 1 + Shift + Ctrl）
local CSI_CTRL_SHIFT_W = "\x1b[87;6u" -- Ctrl+Shift+W
local CSI_CTRL_SHIFT_TAB = "\x1b[9;6u" -- Ctrl+Shift+Tab（Tab 无大小写问题）
local CSI_CTRL_TAB = "\x1b[9;5u" -- Ctrl+Tab（5 = 1 + Ctrl）

-- Helper functions
-- 到边缘的行为在 utils/pane_nav.lua（与 SMART_SPLITS_REQ 那条路径共用同一份实现）
local pane_nav = require("utils.pane_nav")
local mux = require("utils.mux")

-- mods 里带 Leader 时，动作做完进入 activate_pane 表（可连续操作 600ms）
local function enter_pane_key_table(window, pane, mods)
	if mods and string.lower(mods):find("leader") then
		window:perform_action(
			act.ActivateKeyTable({ name = "activate_pane", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function activate_pane_or_tab_callback(window, pane, dir, mods)
	pane_nav.activate_pane_or_tab(window, pane, dir)
	enter_pane_key_table(window, pane, mods)
end

local function activate_pane_or_tab(dir, mods)
	return function(window, pane)
		activate_pane_or_tab_callback(window, pane, dir, mods)
	end
end

local function resize_pane_with_dir(dir)
	return function(window, pane)
		window:perform_action(act.AdjustPaneSize({ dir, 10 }), pane)
		window:perform_action(
			act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function activate_tab_with_dir(dir)
	return function(window, pane)
		window:perform_action(act.ActivateTabRelative(dir), pane)
		window:perform_action(
			act.ActivateKeyTable({ name = "activate_tab", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function move_tab_with_dir(dir)
	return function(window, pane)
		window:perform_action(act.MoveTabRelative(dir), pane)
		window:perform_action(
			act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 600 }),
			pane
		)
	end
end

local function smart_split_callback(window, pane)
	local dim = pane:get_dimensions()
	if dim.pixel_height > dim.pixel_width then
		window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
	else
		window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
	end
end

-- ── 透传策略：这个键该由谁处理 ──────────────────────────────────────────
-- 在复用器里（或前台是 nvim）→ 原样送进 pane，交给内层程序；
-- 否则返回 false，让调用方执行 wezterm 自己的动作。
-- 「这个 pane 由谁在管」的判定在 utils/mux.lua（那条判据是多路径共用的）；
-- 留在本文件的是键位专属的那半：送键 or 不送。
-- 这部分原先单独是 keybindings/passthrough.lua，但只有本文件用它，
-- 所以收进这里，让 keybindings/ 只留 init.lua 会 apply 的模块。

local function is_one_tab(pane)
	return #pane:window():tabs() == 1
end

local function is_one_pane(pane)
	return #pane:tab():panes() == 1
end

-- 原样送键（wezterm 按当前协商的键盘协议编码，不用手拼 CSI-u）
local function send_key(window, pane, key, mods)
	window:perform_action(act.SendKey({ key = key, mods = mods }), pane)
end

local function should_pass(pane, include_nvim)
	if include_nvim == nil then
		include_nvim = true
	end
	return mux.is_mux(pane) or (include_nvim and mux.is_nvim(pane))
end

-- 需要透传就送键并返回 true；否则返回 false
local function send_if_needed(window, pane, key, mods, include_nvim)
	if not should_pass(pane, include_nvim) then
		return false
	end
	send_key(window, pane, key, mods)
	return true
end

-- ── Alt 系键：先判断归属，再决定透传还是自己处理 ──────────────────────────
-- 在复用器里（或前台是 nvim）→ 原样送进 pane；否则执行 wezterm 的动作。
--
-- 这里原来是「一张 ACTION_HANDLERS 表 + 按 action 字符串查表」，改成由调用点直接给出
-- 函数，因为那张表有两个毛病：
--   * 它混着两种契约 —— 多数 entry 返回动作（由调用方 perform），ActivatePaneDirection
--     和 smart_split 却自己 perform。调用方只能靠 `if result` 猜，而"返回 nil"在两种
--     语义下都说得通（工厂的 nil 本该是"这次什么也不做"），谁加一个带条件的工厂就会
--     静默变成"这个键没反应"。
--   * 表用字符串键，action 名打错一个字母不会报错，只会掉进 else 把原键送出去 ——
--     不在复用器里就是"键悄悄失效"，在 nvim/tmux 里则看起来"差不多对"，最难查。
--     （那张表里当时还有 5 个 entry 是死的：ActivateTabRelative / MoveTabRelative /
--      SpawnTab / CloseCurrentTab / CloseCurrentPane，13 个调用点一个都没用到。）
-- 现在契约由函数名区分，拼写错误是加载期报错而不是运行期静默。

--- 透传，或执行一个由参数造出来的动作（动作由这里 perform）
---@param arg any 传给 build 的参数（方向 / tab 序号 / 动作参数表）
---@param build fun(arg:any): table
local function passthrough_or_action(mods, key, arg, build)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(window, pane)
			if send_if_needed(window, pane, key, mods, true) then
				return
			end
			window:perform_action(build(arg), pane)
		end),
	}
end

--- 透传，或执行一个自执行回调（它自己 perform，可能 perform 不止一个动作）
---@param fn fun(window, pane)
local function passthrough_or_callback(mods, key, fn)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(window, pane)
			if send_if_needed(window, pane, key, mods, true) then
				return
			end
			fn(window, pane)
		end),
	}
end
--------------------------------------------------------------------------------
-- 新建 tab 落在**当前 tab 的右边**（Chrome 式），而不是 wezterm 默认的标签栏末尾。
-- 只给 `Ctrl+Shift+T` 用；`Leader+c` 保持 wezterm 原生 SpawnTab（追加到末尾），不接管。
--
-- wezterm 没有能改落点的开关：SpawnTab 一律走 mux/src/lib.rs 的 add_tab_to_window →
-- Window::push_tab（`tabs: Vec<Arc<Tab>>` 的 push），整个仓库只有 move_tab（tab 重排）会用到
-- insert_tab_at_idx。所以这里自己接管两步：
--
--   1) 建 tab 必须用 Lua mux API `window:spawn_tab{}`，**不能**用 act.SpawnTab：
--      后者在 wezterm-gui/src/spawn.rs 里是 promise::spawn + detach，perform_action 立刻返回，
--      那一刻按 tabs() 数出来的"新 tab"还是旧的那个，挪的就是当前 tab 本身。而 spawn_tab 是
--      async Lua 方法，action_callback 又是由 config::lua::emit_event 的 call_async 调起来的
--      （wezterm-gui/src/termwindow/mod.rs 的 schedule_window_event），所以 await 完才返回，
--      回来时新 tab 已经在 mux 的 tabs() 里、并且已被设为活动 tab。
--      domain 不传就是 CurrentPaneDomain（SpawnTabDomain 的 Default），与原来的
--      act.SpawnTab("CurrentPaneDomain") 等价。
--   2) 再用 MoveTab 把新 tab（此刻的活动 tab）挪到原活动 tab 的后一位。
--
-- 索引换算：Lua 的 tabs() 是 1-based、MoveTab 是 0-based，"原活动 tab 在第 i 位"时目标索引
-- 正好也是 i。原来就停在末尾（i == 原数量）时不用挪 —— spawn 出来的新 tab 天然在它右边。
local function spawn_tab_after_current(window, pane)
	local mux_window = pane:window()
	local active_id = mux_window:active_tab():tab_id()

	local pos
	local before = 0
	for i, tab in ipairs(mux_window:tabs()) do
		before = i
		if tab:tab_id() == active_id then
			pos = i
		end
	end

	mux_window:spawn_tab({})

	if pos ~= nil and pos < before then
		window:perform_action(act.MoveTab(pos), pane)
	end
end
--------------------------------------------------------------------------------

M.keys = {
	-- ── 全局 ──
	-- 粘贴系统剪贴板
	{ key = "V", mods = "SHIFT|CTRL", action = act({ PasteFrom = "Clipboard" }) },
	-- 粘贴主选区
	{ key = "S", mods = "SHIFT|CTRL", action = act({ PasteFrom = "PrimarySelection" }) },
	-- 复制到剪贴板
	{ key = "C", mods = "SHIFT|CTRL", action = act({ CopyTo = "Clipboard" }) },
	-- 搜索
	{ key = "F", mods = "SHIFT|CTRL", action = act.Search({ CaseSensitiveString = "" }) },
	-- 命令面板
	{ key = "P", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
	{ key = "+", mods = "SHIFT|CTRL", action = act.IncreaseFontSize },
	{ key = "_", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
	{ key = ")", mods = "SHIFT|CTRL", action = act.ResetFontSize },
	-- 全屏切换
	{ key = "F11", mods = "", action = "ToggleFullScreen" },

	-- 进入 activate_pane 表：h j k l / 方向键 / o O，q 或 Esc 退出
	{
		key = "a",
		mods = "CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "activate_pane", one_shot = false, timeout_milliseconds = 5000 }),
	},
	-- 进入 activate_tab 表：n p 相对切、N P 到末/首，q 或 Esc 退出
	{
		key = "A",
		mods = "SHIFT|CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "activate_tab", one_shot = false, timeout_milliseconds = 5000 }),
	},
	-- 进入 resize_pane 表：方向键 / hjkl 1 格、Shift 10 格，q 或 Esc 退出
	{
		key = "r",
		mods = "CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 5000 }),
	},
	-- 进入 move_tab 表：p n 相对移、P N 到首/末，q 或 Esc 退出
	{
		key = "R",
		mods = "SHIFT|CTRL|LEADER",
		action = act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 5000 }),
	},

	-----------WORKSPACES----------
	-- 切换到上一个工作区
	{ key = "E", mods = "SHIFT|LEADER", action = workspace_switcher.switch_to_prev_workspace() },
	-- 切换工作区（smart_workspace_switcher）
	{ key = "e", mods = "LEADER", action = workspace_switcher.switch_workspace() },
	-- 锁定 / 解锁：所有键原样交给 pane 内程序（等价 zellij Locked），再按一次退出
	{ key = "g", mods = "LEADER", action = wezterm.action_callback(toggle_lock) },
	-- Leader+f：跨 pane 模糊搜索（Lua 收集候选 + fzf 显示），**含全部历史**。
	-- 历史用 Lua API 直接取：get_lines_as_text(nlines) / get_lines_as_escapes(nlines)，
	-- nlines 取 scrollback_rows + viewport_rows（整屏 + 全部历史）—— 全程没有 wezterm cli 进程，毫秒级。
	-- 预览读的是采集时落盘的同一份文本，行号按物理行算（细节见 utils/find_pane.lua）。

	-- 跨 pane 模糊搜索（Lua 收集候选 + fzf 显示，右侧预览定位到选中行）→ 可见区 + 全部 scrollback、无上限，零 CLI 进程
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local function toast(msg)
				pcall(function()
					window:toast_notification("find pane", tostring(msg), 5000)
				end)
			end
			local ok, mod = pcall(dofile, wezterm.config_dir .. "/utils/find_pane.lua")
			if not ok then
				toast("加载 find_pane.lua 失败: " .. tostring(mod))
				return
			end
			local ran, action, err = pcall(mod.fzf_action_for, window, pane, { scrollback = true })
			if not ran then
				toast("fzf_action_for 出错: " .. tostring(action))
				return
			end
			if action then
				window:perform_action(action, pane)
			elseif err then
				toast(err)
			end
		end),
	},
	-- 借用 wezterm 原生搜索（同 Ctrl+Shift+F 的 action）：搜当前 pane 的屏幕 + 滚动历史
	{ key = "F", mods = "SHIFT|LEADER", action = act.Search({ CaseSensitiveString = "" }) },
	-----------PANE------------
	-- 关闭当前 pane
	{ key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = false } }) },
	-- 切换 pane zoom
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	-- 选中 pane 并与当前 pane 交换（PaneSelect SwapWithActive）
	{ key = "S", mods = "SHIFT|LEADER", action = act.PaneSelect({ mode = "SwapWithActive" }) },
	{ key = "O", mods = "ALT|LEADER", action = act.RotatePanes("Clockwise") },
	{ key = "o", mods = "ALT|LEADER", action = act.RotatePanes("CounterClockwise") },

	-- ── Pane navigation ──
	passthrough_or_callback("ALT", "h", activate_pane_or_tab("Left")),
	passthrough_or_callback("ALT", "j", activate_pane_or_tab("Down")),
	passthrough_or_callback("ALT", "k", activate_pane_or_tab("Up")),
	passthrough_or_callback("ALT", "l", activate_pane_or_tab("Right")),

	-- Alt+[ / Alt+] 传进来的就是 Prev/Next，由 utils/pane_nav.lua 的 directions 表决定"不跨 tab"
	passthrough_or_callback("ALT", "[", activate_pane_or_tab("Prev")),
	passthrough_or_callback("ALT", "]", activate_pane_or_tab("Next")),

	-- pane 编号选择（1-9）
	{ key = "s", mods = "LEADER", action = act.PaneSelect({ alphabet = "123456789" }) },

	{ key = "o", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Next", "LEADER")) },
	{ key = "O", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Prev", "LEADER")) },

	{ key = "k", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Up", "LEADER")) },
	{ key = "j", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Down", "LEADER")) },
	{ key = "h", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Left", "LEADER")) },
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action_callback(activate_pane_or_tab("Right", "LEADER")),
	},
	{ key = "UpArrow", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Up", "LEADER")) },
	{ key = "DownArrow", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Down", "LEADER")) },
	{ key = "LeftArrow", mods = "LEADER", action = wezterm.action_callback(activate_pane_or_tab("Left", "LEADER")) },
	{
		key = "RightArrow",
		mods = "LEADER",
		action = wezterm.action_callback(activate_pane_or_tab("Right", "LEADER")),
	},
	{ key = "h", mods = "ALT|CTRL", action = wezterm.action_callback(activate_pane_or_tab("Left")) },
	{ key = "l", mods = "ALT|CTRL", action = wezterm.action_callback(activate_pane_or_tab("Right")) },
	{ key = "k", mods = "ALT|CTRL", action = wezterm.action_callback(activate_pane_or_tab("Up")) },
	{ key = "j", mods = "ALT|CTRL", action = wezterm.action_callback(activate_pane_or_tab("Down")) },

	-- ── Pane resize ──
	-- 步长 5：Leader 系的 resize 表用 10，两者有意不同
	passthrough_or_action("ALT", "LeftArrow", { "Left", 5 }, act.AdjustPaneSize),
	passthrough_or_action("ALT", "RightArrow", { "Right", 5 }, act.AdjustPaneSize),
	passthrough_or_action("ALT", "UpArrow", { "Up", 5 }, act.AdjustPaneSize),
	passthrough_or_action("ALT", "DownArrow", { "Down", 5 }, act.AdjustPaneSize),

	{ key = "H", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Left")) },
	{ key = "J", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Down")) },
	{ key = "K", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Up")) },
	{ key = "L", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Right")) },
	{ key = "UpArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Up")) },
	{ key = "DownArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Down")) },
	{ key = "LeftArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Left")) },
	{ key = "RightArrow", mods = "SHIFT|LEADER", action = wezterm.action_callback(resize_pane_with_dir("Right")) },
	{ key = "H", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Left", 10 }) },
	{ key = "J", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Down", 10 }) },
	{ key = "K", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Up", 10 }) },
	{ key = "L", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Right", 10 }) },

	-- ── Pane splitting ──
	-- 智能分割：按 pane 长宽比选上下或左右
	passthrough_or_callback("ALT", "n", smart_split_callback),
	-- 智能分割
	{ key = "Enter", mods = "LEADER", action = wezterm.action_callback(smart_split_callback) },
	-- 智能分割
	{ key = "Enter", mods = "ALT|CTRL", action = wezterm.action_callback(smart_split_callback) },
	-- 智能分割（按 pane 长宽比，同 Leader+Enter）
	{ key = "Enter", mods = "SHIFT|CTRL", action = wezterm.action_callback(smart_split_callback) },
	{ key = "-", mods = "ALT|CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "ALT|CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-----------TAB----------
	-- 新建 tab（wezterm 原生 SpawnTab，新 tab 追加到标签栏末尾，不接管落点）
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	-- 关闭 tab（与 Leader+q 同）
	{ key = "&", mods = "SHIFT|LEADER", action = act.CloseCurrentTab({ confirm = false }) },
	-- 关闭 tab（不确认）
	{ key = "q", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
	-- tab 导航器
	{ key = "w", mods = "LEADER", action = act.ShowTabNavigator },
	-- tab 导航器（A = all tabs）
	{ key = "A", mods = "SHIFT|CTRL", action = act.ShowTabNavigator },

	-- ── Tab navigation ──
	{ key = "LeftArrow", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(1) },
	{ key = "[", mods = "ALT|CTRL", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "ALT|CTRL", action = act.ActivateTabRelative(1) },
	{ key = "n", mods = "LEADER", action = wezterm.action_callback(activate_tab_with_dir(1)) },
	{ key = "p", mods = "LEADER", action = wezterm.action_callback(activate_tab_with_dir(-1)) },
	{ key = "0", mods = "LEADER", action = act({ ActivateTab = -1 }) },
	{ key = "0", mods = "ALT|CTRL", action = act({ ActivateTab = -1 }) },
	passthrough_or_action("ALT", "0", -1, act.ActivateTab),

	-- ── Tab movement ──
	{ key = "<", mods = "SHIFT|CTRL", action = act.MoveTabRelative(-1) },
	{ key = ">", mods = "SHIFT|CTRL", action = act.MoveTabRelative(1) },
	{ key = "{", mods = "SHIFT|ALT|CTRL", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "SHIFT|ALT|CTRL", action = act.MoveTabRelative(1) },
	{ key = "P", mods = "SHIFT|LEADER", action = wezterm.action_callback(move_tab_with_dir(-1)) },
	{ key = "N", mods = "SHIFT|LEADER", action = wezterm.action_callback(move_tab_with_dir(1)) },

	-- ── Scrolling ──
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-0.5) },
	{ key = "PageUp", mods = "SHIFT|CTRL", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(0.5) },
	{ key = "PageDown", mods = "SHIFT|CTRL", action = act.ScrollByPage(1) },
	{ key = "Home", mods = "SHIFT|CTRL", action = act.ScrollToTop },
	{ key = "End", mods = "SHIFT|CTRL", action = act.ScrollToBottom },
	{ key = "K", mods = "SHIFT|CTRL", action = act.ScrollByLine(-3) },
	{ key = "J", mods = "SHIFT|CTRL", action = act.ScrollByLine(3) },
	{ key = "UpArrow", mods = "SHIFT|CTRL", action = act.ScrollByLine(-1) },
	{ key = "DownArrow", mods = "SHIFT|CTRL", action = act.ScrollByLine(1) },
	-- 清空 scrollback（同 Ctrl+Shift+Delete）
	{ key = "k", mods = "SUPER", action = act.ClearScrollback("ScrollbackAndViewport") },
	-- 清空 scrollback（同 Super+k）
	{ key = "Delete", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },

	-- ── Copy mode ──
	{ key = "Escape", mods = "LEADER", action = act.ActivateCopyMode },
	-- 进入复制模式
	{ key = "[", mods = "CTRL|LEADER", action = act.ActivateCopyMode },
	{ key = "/", mods = "LEADER", action = act.ActivateCopyMode },
	-- 复制模式 + cell 选择
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(act.ActivateCopyMode, pane)
			window:perform_action(act.CopyMode({ SetSelectionMode = "Cell" }), pane)
		end),
	},
	-- 复制模式 + line 选择
	{ key = "V",
		mods = "SHIFT|LEADER",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(act.ActivateCopyMode, pane)
			window:perform_action(act.CopyMode({ SetSelectionMode = "Line" }), pane)
		end),
	},
	-- 复制模式 + block 选择
	{ key = "v",
		mods = "CTRL|LEADER",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(act.ActivateCopyMode, pane)
			window:perform_action(act.CopyMode({ SetSelectionMode = "Block" }), pane)
		end),
	},

	-- ── OSC 133 ──
	{ key = "UpArrow", mods = "SHIFT", action = act.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "SHIFT", action = act.ScrollToPrompt(1) },

	-- ── other ──
	-- 启动器（ShowLauncher）
	{ key = "Space", mods = "LEADER", action = act.ShowLauncher },
	-- QuickSelect（快速选字词）
	{ key = "Space", mods = "SHIFT|CTRL", action = act.QuickSelect },
	-- 显示 debug overlay
	{ key = "F12", mods = "LEADER", action = act.ShowDebugOverlay },
	-- 切换窗口透明度（配置值 ↔ 完全不透明）
	{ key = "o", mods = "CTRL|LEADER", action = wezterm.action.EmitEvent("toggle-opacity") },
	-- 关闭 tab：多 tab 时关；单 tab 时透传进 pane
	{
		key = "W",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				window:perform_action(act({ CloseCurrentTab = { confirm = true } }), pane)
				return
			end
			if should_pass(pane, false) and is_one_pane(pane) then
				window:perform_action(act.SendString(CSI_CTRL_SHIFT_W), pane)
				return
			end
			window:perform_action(act({ SpawnTab = "CurrentPaneDomain" }), pane)
			window:perform_action(act({ ActivateTabRelative = -1 }), pane)
			window:perform_action(act({ CloseCurrentTab = { confirm = true } }), pane)
		end),
	},
	-- 新建 tab（插在当前 tab 右边）：多 tab 时 wezterm 建；单 tab 时把 CSI 字节写进 pane
	{
		key = "T",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				spawn_tab_after_current(window, pane)
				return
			end
			if should_pass(pane, false) and is_one_pane(pane) then
				window:perform_action(act.SendString(CSI_CTRL_SHIFT_T), pane)
			else
				spawn_tab_after_current(window, pane)
			end
		end),
	},
	{
		key = "Tab",
		mods = "SHIFT|CTRL",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				window:perform_action(act.ActivateTabRelative(-1), pane)
				return
			end
			window:perform_action(act.SendString(CSI_CTRL_SHIFT_TAB), pane)
		end),
	},
	{
		key = "Tab",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			if not is_one_tab(pane) then
				window:perform_action(act.ActivateTabRelative(1), pane)
				return
			end
			window:perform_action(act.SendString(CSI_CTRL_TAB), pane)
		end),
	},
	-- 有选区则复制，否则原样透传给 pane
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }), pane)
				window:perform_action("ClearSelection", pane)
			else
				window:perform_action(wezterm.action({ SendKey = { key = "c", mods = "CTRL" } }), pane)
			end
		end),
	},
	-- ── mux_window ──
	{
		key = "i",
		mods = "LEADER",
		action = wezterm.action.AttachDomain("unix"),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.DetachDomain({ DomainName = "unix" }),
	},
	-- 把 pane 移到新窗口 / 指定工作区（空输入=新窗口）
	{
		key = ".",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter target workspace(empty) for move",
			initial_value = "q",
			action = wezterm.action_callback(function(_, pane, line)
				if line == "q" or line == "quit" then
					return
				elseif line ~= "" then
					pane:move_to_new_window(line)
				else
					if #pane:window():tabs() == 1 then
						return
					end
					pane:move_to_new_window()
				end
			end),
		}),
	},
	-- 重命名当前 tab
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- 重命名工作区
	{
		key = "$",
		mods = "SHIFT|LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for workspace",
			action = wezterm.action_callback(function(_, _, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},
	-- 把 pane 移到新 tab
	{
		key = "!",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(_, pane)
			pane:move_to_new_tab()
		end),
	},
	-- 启动器：domains / workspaces / tabs
	{
		key = "`",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({
			flags = "DOMAINS|WORKSPACES|TABS",
		}),
	},

	-- 把最近一次命令输出写进剪贴板（OSC133 + wl-copy）
	{ key = "C", mods = "SHIFT|ALT|CTRL", action = wezterm.action({ EmitEvent = "save-output" }) },
}

function M.apply(config)
	for i = 1, 9 do
		table.insert(M.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
		table.insert(M.keys, { key = tostring(i), mods = "ALT|CTRL", action = act.ActivateTab(i - 1) })
		table.insert(M.keys, passthrough_or_action("ALT", tostring(i), i - 1, act.ActivateTab))
	end
	config.keys = M.keys
end

return M
