-- pane 前台进程名缓存：wezterm 为画标签栏（format-tab-title）本就会算好
-- PaneInformation.foreground_process_name，这里顺手存下来给键位判定用
-- （键位回调只有 Pane 对象，拿不到 PaneInformation）。
-- 键为 pane_id，带写入时间戳，读取方自行决定新鲜度阈值。

local M = {}

-- [pane_id(string)] = { name = string, at = os.time() }
M.panes = {}

local function record(info)
	if not info or not info.pane_id then
		return
	end
	local name = info.foreground_process_name
	if name == nil or name == "" then
		return
	end
	local id = tostring(info.pane_id)
	if M.panes[id] and M.panes[id].name == name then
		M.panes[id].at = os.time()
		return
	end
	M.panes[id] = { name = name, at = os.time() }
end

-- 前台进程名是否说明“当前 pane 由复用器托管”。
-- tmux / zellij 都会成为宿主终端该 pane 的前台进程（wezterm 视角），
-- 用 basename 精确比较，避免误伤 mytmux.sh 这类脚本名。
function M.name_is_mux(name)
	if not name then
		return false
	end
	local base = name:match("([^/\\]+)$") or name
	return base == "tmux" or base == "zellij"
end

-- 只读缓存：返回 true/false，缓存缺失或超过 max_age 秒时返回 nil（交给调用方决定是否回退查询）
function M.is_mux_cached(pane_id, max_age)
	local entry = M.panes[tostring(pane_id)]
	if not entry then
		return nil
	end
	if max_age and (os.time() - entry.at) >= max_age then
		return nil
	end
	return M.name_is_mux(entry.name)
end

-- panes: format-tab-title 的第三个参数（该 tab 的 PaneInformation 列表）
-- active_pane: tab.active_pane（同一份信息的当前 pane）
function M.update(panes, active_pane)
	if panes then
		for _, info in ipairs(panes) do
			record(info)
		end
	end
	record(active_pane)
end

function M.get(pane_id)
	return M.panes[tostring(pane_id)]
end

return M
