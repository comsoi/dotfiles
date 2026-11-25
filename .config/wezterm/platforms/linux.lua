-- Linux 平台设置

local M = {}

---这次会话是不是 Wayland。
---@param session_type string|nil $XDG_SESSION_TYPE；不传则读环境
---@param display string|nil      $WAYLAND_DISPLAY；session_type 为空时用它兜底
---@return boolean
function M.is_wayland(session_type, display)
	session_type = session_type or os.getenv("XDG_SESSION_TYPE")
	if session_type and session_type ~= "" then
		return session_type == "wayland"
	end
	display = display or os.getenv("WAYLAND_DISPLAY")
	return display ~= nil and display ~= ""
end

---桌面环境是不是 GNOME（含 "ubuntu:GNOME" 这类写法）。
---@param desktop string|nil XDG_CURRENT_DESKTOP:XDG_SESSION_DESKTOP；不传则读环境
---@return boolean
function M.is_gnome(desktop)
	if desktop == nil then
		desktop = (os.getenv("XDG_CURRENT_DESKTOP") or "") .. ":" .. (os.getenv("XDG_SESSION_DESKTOP") or "")
	end
	return desktop:lower():find("gnome", 1, true) ~= nil
end

---Wayland 下该用哪档 window_decorations；nil = 不该覆盖（X11 那边由 WM 处理）。
---
---为什么分两档：谁能画 SSD 完全看合成器，而两者实测结果相反 ——
---  * GNOME/mutter **不给 Wayland 原生客户端画服务端装饰**（xdg-decoration 恒回 client_side），
---    所以只能让 wezterm 自绘，否则窗口全裸、也没法拖。
---  * KWin 与 Hyprland 对 set_mode(server_side) 都回 SERVER_SIDE（本机用独立探针实测过），
---    所以用 "NONE" 把装饰交给合成器 —— 拿到的是**原生标题栏**，而不是 sctk-adwaita 那条灰条。
---
---自绘那档必须是 "TITLE|RESIZE" 而**不是**只写 "TITLE"：
---  RESIZE 控制 sctk-adwaita 边框八个边的拖拽调整（pointer.rs 里
---  `Location::Top if resizable => FrameAction::Resize(..)`，八个边全带这个条件）以及边缘的
---  调整光标。少了它标题栏在、边框却拖不动 —— 正是 PR #7095 想修的"无法拖动"的翻版。
---  （`hide_border(true)` 藏的是视觉边框，点击区域仍由这套 location 判定。）
---  这里写的值和 style/appearance.lua 的默认值一致，是**故意重复**：让本文件的三个分支
---  一眼看全，不用跳去另一个文件才知道 GNOME 拿到什么。
---
---⚠ "NONE" 这一档依赖 wezterm 侧的一个修复：在这份 PR 构建里，`NONE` 曾经因为
---  `initial_decorations` 传了 `Decorations::None`（sctk 于是不创建 decoration 对象，
---  见 sctk 的 `WindowDecorations::None => None`），导致紧随其后的
---  `request_decoration_mode(Server)` 在 `if let Some(toplevel_decoration)` 处空转，
---  `set_mode(server_side)` 从未发出 → 既无 SSD 也无 CSD，窗口全裸。
---  修在本地克隆 `~/builds/wezterm-7924-7095` 的提交 f506ffecf：
---  `initial_decorations` 统一成 `== NONE ? RequestServer : RequestClient`。
---  **没装那个包之前，"NONE" 等于全裸**，那时应该临时用 "TITLE|RESIZE"。
---X11 那档为什么是"不覆盖"（返回 nil）：那边 window_decorations 会被翻译成
---`_MOTIF_WM_HINTS` 发给 WM（window/src/os/x11/window.rs 的 adjust_decorations），按值分派：
---  `TITLE|RESIZE` → `MWM_DECOR_ALL`(1)
---  `RESIZE`       → `MWM_DECOR_BORDER`(2)
---  `TITLE`        → 60（TITLE/MENU/MINIMIZE/RESIZEH 位）
---  `NONE`         → 0
---**但 WM 怎么解读这套位是 WM 自己的事，不能想当然。** 以 GNOME 的 Mutter 为例
---（mutter/src/x11/window-props.c 的 reload_mwm_hints）：
---  * `mwm_decorated` 初始化就是 **TRUE**；
---  * 只特判两个值 —— `0` → 不要装饰；`MWM_DECOR_BORDER`(2) → 只留边框；
---  * **其余任何值（含 1 和 60）它都不动** → 照旧画**完整**装饰。
---所以 X11 + GNOME：wezterm 一个字不改（`TITLE|RESIZE`）就能拿到 Mutter 画的完整 SSD，
---而且 `TITLE` 与 `TITLE|RESIZE` 在 Mutter 上**行为相同**（它不按位解析）。保留 RESIZE 是为了
---按位解析的 WM，以及和 Wayland 那档保持一致（那边 RESIZE 真的管边框拖拽）。
---反过来：X11 下给 `NONE` 就是"无装饰"，而 wezterm 的 X11 后端**没有任何自绘代码**
---（`window/src/os/x11/` 下没有 AdwaitaFrame / FrameConfig），不会兜底 —— 这正是下面要挡住
---`enable_wayland = false` 的原因。
---@param session_type string|nil
---@param display string|nil
---@param desktop string|nil
---@param enable_wayland boolean|nil config.enable_wayland。显式 false 时 wezterm 强制走
---       X11（XWayland），此时就算 WAYLAND_DISPLAY 还在也不能按 Wayland 那套来 ——
---       那会让 "NONE" 变成"无装饰"。不传/nil 按默认（true）处理。
---@return string|nil
function M.wayland_decorations(session_type, display, desktop, enable_wayland)
	if enable_wayland == false then
		return nil
	end
	if not M.is_wayland(session_type, display) then
		return nil
	end
	return M.is_gnome(desktop) and "TITLE|RESIZE" or "NONE"
end

function M.apply(config)
	config.launch_menu = {
		{ label = "zsh",  args = { "zsh"  } },
		{ label = "fish", args = { "fish" } },
		{ label = "bash", args = { "bash" } },
		{ label = "tmux", args = { "tmux" } },
	}
	config.default_prog = { "zsh" }
	-- config.default_gui_startup_args = { "start", "sh", "-c", "sleep 0.1; exec zsh" }
	-- 必须在平台层（后加载）覆盖掉 style/appearance.lua 的 "TITLE|RESIZE" —— 那正是
	-- X11/Windows 想要的值（X11 下它会变成 _MOTIF_WM_HINTS 的 MWM_DECOR_ALL），
	-- 只有 Wayland 需要按合成器分档。理由与三档取值见 M.wayland_decorations 的注释。
	local decor = M.wayland_decorations(nil, nil, nil, config.enable_wayland)
	if decor then
		config.window_decorations = decor
	end
	config.unicode_version = 14
	-- if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then
	-- 	config.dpi = 384
	-- end
end

return M
