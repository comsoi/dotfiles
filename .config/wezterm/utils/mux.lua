-- 复用器 / nvim 判定（唯一入口，keybindings 与 style 共用）。
-- 判定顺序：标签栏缓存的进程名（wezterm 本就要算，零开销）→ 直接查前台进程名
-- （结果按 pane 缓存）。“跑 zellij/tmux 的 pane，其前台进程就是它”。

local M = {}

local proc_cache_module = require("utils.pane_proc_cache")

local proc_cache = {} -- [pane_id] = { at = os.time(), is_mux = bool }
local PROC_TTL_SECONDS = 2 -- 直接查询结果的缓存时长
local CACHE_FRESH_SECONDS = 5 -- 采信标签栏缓存的新鲜度窗口

function M.is_mux(pane)
	local key = tostring(pane:pane_id())
	local cache = proc_cache_module

	-- 这里曾经先查 user_vars.TMUX / user_vars.ZELLIJ 当快路径，但那是死代码：
	-- wezterm 从不设置这两个名字（它的内建变量叫 WEZTERM_IN_TMUX，且只由 shell
	-- integration 引入，本仓库没装），本仓库也没有任何地方设过；而下一条的
	-- name_is_mux 已经按前台进程 basename 识别 tmux / zellij。留着只会每次按键
	-- 白拷一份 user vars。要恢复快路径请用 WEZTERM_IN_TMUX == "1"，别再写 TMUX。
	local cached_mux = cache.is_mux_cached(key, CACHE_FRESH_SECONDS)
	if cached_mux ~= nil then
		return cached_mux
	end

	local now = os.time()
	local cached = proc_cache[key]
	if cached and (now - cached.at) < PROC_TTL_SECONDS then
		return cached.is_mux
	end

	local ok, name = pcall(function()
		return pane:get_foreground_process_name()
	end)
	local is_mux = ok and cache.name_is_mux(name) or false
	proc_cache[key] = { at = now, is_mux = is_mux }
	return is_mux
end

-- 前台是 nvim（smart-splits 经 OSC 1337 上报 IS_NVIM；zellij 会过滤该序列）
function M.is_nvim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
end

return M
