-- 平台判断：唯一的 target_triple 读取点，供 platforms/ 与 utils/ 共用。
--
-- 用子串匹配而不是精确相等：官方的 x86_64-unknown-linux-gnu / x86_64-pc-windows-msvc
-- 只是其中两个值，aarch64-pc-windows-msvc 这类同族 triple 也要能被识别。
-- 注意这里只管「平台」；会话层判断（如 WAYLAND_DISPLAY 区分 X11/Wayland）不属于这里。

local wezterm = require("wezterm")

local M = {}

function M.triple()
	return wezterm.target_triple or ""
end

function M.is_linux()
	return M.triple():find("linux") ~= nil
end

function M.is_windows()
	return M.triple():find("windows") ~= nil
end

function M.is_macos()
	return M.triple():find("darwin") ~= nil
end

return M
