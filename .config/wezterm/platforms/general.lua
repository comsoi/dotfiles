local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.check_for_updates = false
	config.term = "wezterm"
	config.max_fps = 165
	config.animation_fps = 165
	config.initial_cols = 120
	config.initial_rows = 35
	config.scrollback_lines = 9000
	config.audible_bell = "Disabled"
	config.ssh_domains = {}
	config.warn_about_missing_glyphs=false

	-- 让初始窗口继承调用者 cwd —— wezterm 原生只有 --cwd → default_cwd → home 三条路
	-- （官方 default_cwd 文档的流程图），不像 kitty/alacritty 那样默认继承。
	-- 配置在 CLI 进程里求值，所以这里的 pwd 就是调用者目录；算出来是绝对路径，复用已有
	-- 实例时随 SpawnV2 一起送过去，不会被对端重新解析成它自己的 cwd。--cwd 仍然优先
	-- （含 xdg-terminal-exec 注入的 --cwd=），所以它只管"没指定目录"那种情况。
	-- type 守卫是因为测试的 fake wezterm.run_child_process 默认返回 ({}, 0)；
	-- Windows 上没有 pwd，返回 false，这里自动跳过。
	local ok, cwd = wezterm.run_child_process({ "pwd" })
	if ok and type(cwd) == "string" and cwd ~= "" then
		config.default_cwd = (cwd:gsub("%s+$", ""))
	end
end

return M
