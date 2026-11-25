-- config override 的共享读写：所有需要临时改 colors 的地方都走这里。
--
-- 背景：wezterm 的 colors 在 override 里是"整表替换"——只给 colors.scrollbar_thumb
-- 会把其余颜色打回 scheme 的值，所以想临时改一个颜色，必须给出一份完整的 colors。
-- 但**不能**直接 `overrides.colors = config.colors`：那样 overrides 里的 colors 和
-- 全局 config 表是同一个 Lua 表，写 override 就等于写全局配置；而多个
-- update-status handler 各自读-改-写同一张 colors，谁拿 config 里的旧值整体覆盖，
-- 就会把对方刚设的键打回原值（tab bar 底色在"填实的模式色 / 透明的默认色"之间闪，
-- 就是这么来的）。
--
-- 这里统一成：以 base（config.colors）为底 → 叠上当前 override 里已有的颜色
-- （保住其他 handler 设过的键）→ 交给调用方改自己的键 → 整体写回。全程只碰副本。

local M = {}

function M.copy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for k, v in pairs(value) do
		copy[M.copy(k)] = M.copy(v)
	end
	return copy
end

local function merge_into(dst, src)
	for k, v in pairs(src) do
		if type(v) == "table" and type(dst[k]) == "table" then
			merge_into(dst[k], v)
		else
			dst[k] = M.copy(v)
		end
	end
	return dst
end

-- overrides 可传调用方刚读出的那张表，省一次 get_config_overrides；
-- mutate(overrides, colors) 里改 colors 之外的键也可以。
function M.update_colors(window, overrides, base_colors, mutate)
	overrides = overrides or window:get_config_overrides() or {}
	local colors = M.copy(base_colors or {})
	if type(overrides.colors) == "table" then
		merge_into(colors, overrides.colors)
	end
	overrides.colors = colors
	mutate(overrides, colors)
	window:set_config_overrides(overrides)
	return overrides
end

return M
