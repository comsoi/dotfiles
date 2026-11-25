-- Ctrl+Alt+Shift+C：把最近一次命令的输出（OSC 133 的 Output 语义区）写进剪贴板。
--
-- 多平台：wezterm 没给 Lua 提供"写剪贴板"的 API（只有 window:get_clipboard()，
-- 二进制里并不存在 set_clipboard 这个方法），所以只能按平台挑外部命令。
-- 文本统一从 stdin 喂进去（避开命令行长度与转义问题），候选逐个尝试并**检查退出码**；
-- 全失败就 toast 提示 —— 以前硬编码 wl-copy，在非 Wayland 环境下是静默什么都不做。
--   Wayland → wl-copy（只此一个，不回落 X11 工具）  X11 → xsel / xclip    macOS → pbcopy
--   Windows → PowerShell Set-Clipboard（Unicode）→ clip.exe（只保证当前代码页）
-- xclip 在本机上不稳，所以 X11 候选链一律把 xsel 排在前面，xclip 只作后备。
-- https://github.com/wezterm/wezterm/discussions/2343

local wezterm = require("wezterm")
local target = require("utils.target")
local M = {}

local function has_env(name)
	local v = os.getenv(name)
	return v ~= nil and v ~= ""
end

-- 按优先级返回**命令行**（文本从 stdin 喂进去）
function M.clipboard_commands()
	if target.is_windows() then
		-- clip.exe 走 OEM 代码页（中文会乱码），所以 PowerShell 优先
		return { 'powershell -NoProfile -Command "$input | Set-Clipboard"', "clip.exe" }
	end
	if target.is_macos() then
		return { "pbcopy" }
	end
	if has_env("WAYLAND_DISPLAY") then
		-- 只走原生 Wayland 工具：xsel/xclip 是 X11 客户端，在 Wayland 会话里得靠 Xwayland 桥接，
		-- 容易和原生 selection 互相抢所有权（也正是不稳定来源），失败就交给 toast 提示。
		return { "wl-copy" }
	end
	return { "xsel -ib", "xclip -selection clipboard", "wl-copy" }
end

-- 写进某个命令的 stdin。
-- io.popen 对不存在的命令不会报错，只在 close() 时给出 127 —— 所以必须看退出码才知道成败。
-- 失败时返回 (false, 原因)：原因要能区分"命令不存在（没装）"和"命令在但写失败/非零退出"，
-- 否则上层提示只能笼统说一句"没有可用的剪贴板命令"，把两种完全不同的处置混在一起。
---@return boolean ok, string|nil why
local function pipe_stdin(cmd, text)
	local name = cmd:match("^%S+") or cmd
	local ok, f = pcall(io.popen, cmd, "w")
	if not ok or not f then
		return false, name .. " 启动失败"
	end
	local wrote_ok, write_err = pcall(function()
		f:write(text)
	end)
	local ok2, how, code = f:close()
	if not wrote_ok then
		return false, name .. " 写入失败（" .. tostring(write_err) .. "）"
	end
	if not (ok2 and how == "exit" and code == 0) then
		local detail = how == "exit" and ("退出码 " .. tostring(code)) or tostring(how)
		if how == "exit" and code == 127 then
			detail = detail .. "（命令不存在）"
		end
		return false, name .. " " .. detail
	end
	return true
end

-- 依次尝试候选命令；成功返回 (true, 实际用的命令)，全失败返回 (false, 各候选的失败原因)
function M.copy_to_clipboard(text)
	local reasons = {}
	for _, cmd in ipairs(M.clipboard_commands()) do
		local ok, why = pipe_stdin(cmd, text)
		if ok then
			return true, cmd
		end
		reasons[#reasons + 1] = why
	end
	return false, table.concat(reasons, "；")
end

function M.apply(_)
	wezterm.on("save-output", function(window, pane)
		local zones = pane:get_semantic_zones()
		local last_index = nil
		for i = #zones, 1, -1 do
			if zones[i].semantic_type == "Output" then
				last_index = i
				break
			end
		end
		if not last_index then
			return
		end

		local text = pane:get_text_from_semantic_zone(zones[last_index])
		if not text then
			return
		end

		local ok, detail = M.copy_to_clipboard(text)
		if not ok then
			pcall(function()
				window:toast_notification("save-output", "写剪贴板失败：" .. tostring(detail), 6000)
			end)
		end
	end)
end

return M
