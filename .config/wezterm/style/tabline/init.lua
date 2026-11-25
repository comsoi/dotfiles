local wezterm = require("wezterm")
local cmd_abbr = require("utils.cmd_abbr")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local M = {}

local function tab_title(tab_info)
	if not tab_info.is_active then
		if tab_info.active_pane.domain_name ~= "local" then
			return ""
		elseif #tab_info.tab_title > 0 then
			return tab_info.tab_title .. "|"
		else
			return ""
		end
	end
	-- 压缩标题中嵌入的真实路径（UTF-8 安全）；溢出折叠见 style/tabline/collapse.lua
	local title = tab_info.active_pane.title
	if title:sub(1, 1) == " " then
		title = title:sub(2)
	end
	return cmd_abbr.abbreviate_title(title)
end

-- 段落 c 的提示：锁定 > LEADER，都不显示时返回空串。
-- 只用一个组件：tabline 会在相邻组件之间插分隔符，多一个空组件就会多插一个箭头
-- （拿不到配色时用默认前景色画出来，就是那条白色细尖头）。
-- 锁定判据：keybindings/keys.lua 的 toggle_lock 会清空 keys、只留 Leader+g。
local function status_chip(window)
	local overrides = window:get_config_overrides()
	if overrides and overrides.keys ~= nil then
		return " \u{f023} "
	end
	if window:leader_is_active() then
		return " LEADER "
	end
	return ""
end

function M.apply(config)
	-- 不用 wezterm 的单标签宽度上限（会把长标题截断）；
	-- 实际宽度预算由 style/tabline/collapse.lua 按可用空间计算并截断
	config.tab_max_width = 1000
	-- 必须先于 tabline.setup() 注册：wezterm 只执行第一个 format-tab-title handler
	require("style.tabline.collapse").apply(config)

	local tab_active = {
		"index",
		"⌘ ",
		{ "cwd", padding = 0, max_length = 6 },
		{ "process" },
		tab_title,
		{ "zoomed", padding = 0 },
	}
	if require("platforms.init").is_windows() then
		tab_active = { "index", "⌘ ", tab_title, { "zoomed", padding = 0 } }
	end

	-- 延迟初始化 tabline：setup 本身约 65ms，冷启动时挂到 gui-startup 不阻塞配置求值；
	-- 热重载时（已有窗口存在，gui-startup 不会再触发）必须立即 setup，否则 tabline 丢失
	local tabline_ready = false

	local function setup_tabline()
		if tabline_ready then
			return
		end
		tabline_ready = true
		tabline.setup({
			-- 插件调色板跟随窗口 scheme（插件默认写死 Catppuccin Mocha，
			-- 与 Light 下的 Frappe 窗口混搭会明显偏色）
			options = { theme = config.color_scheme },
				sections = {
					tabline_c = { status_chip },
				tab_active = tab_active,
				tab_inactive = {
					{ "index", padding = 0 },
					". ",
					tab_title,
					{ "process", padding = { left = 0, right = 1 } },
				},
				tabline_x = { { "cpu", throttle = 5 } },
			},
			extensions = { "smart_workspace_switcher" },
		})
		-- 必须晚于 tabline.setup() 注册：窄窗口下整段隐藏右状态依赖 handler 执行顺序
		require("style.tabline.collapse").apply_right_status_control(config)
	end
	-- 注意：GUI 启动早期（mux 就绪前）也会求值配置，all_windows 此时会抛错；
	-- 若让它抛出，整份配置会被丢弃回退默认值（包括 default_gui_startup_args）
	local ok, windows = pcall(wezterm.mux.all_windows)
	if ok and #windows > 0 then
		setup_tabline()
	else
		wezterm.on("gui-startup", setup_tabline)
	end
	-- 标签栏基础配置
	config.show_new_tab_button_in_tab_bar = false
	config.use_fancy_tab_bar = false
	config.show_close_tab_button_in_tabs = false
	config.hide_tab_bar_if_only_one_tab = false
	config.show_tab_index_in_tab_bar = false
	config.tab_bar_at_bottom = true
end

return M
