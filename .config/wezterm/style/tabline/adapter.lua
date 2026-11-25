-- tabline.wez 插件的适配层：把对插件内部结构（tabline.config / tabline.tabs /
-- tabline.component）的依赖收在一处。插件升级或换实现时只改这个文件。
-- 所有读取都保持“拿不到就返回 nil”的语义，调用方自行兜底。

local M = {}

-- 首次加载允许失败（tabline 首次拉取/尚未注册时），失败不缓存、下次重试；
-- 成功后缓存模块表（表本身是稳定的，字段变化照旧可见），热路径上不再 require。
local config_mod
local component_mod
local tabs_mod
local extension_mod

function M.config()
	if not config_mod then
		local ok, c = pcall(require, "tabline.config")
		if ok then
			config_mod = c
		end
	end
	return config_mod
end

-- 插件是否已 setup（options 就绪）
function M.available()
	local c = M.config()
	return c ~= nil and c.opts ~= nil and c.opts.options ~= nil
end

-- 和其它读取一致：拿不到就返回 nil，由调用方兜底。
-- 原先是裸 require —— tabline.tabs 加载失败（插件没装好/路径没进 package.path）会直接在
-- format-tab-title 里抛异常，变成"每个 tab 每次重绘一条错误"，而不是降级。
function M.render_tab(tab, hover)
	if not tabs_mod then
		local ok, mod = pcall(require, "tabline.tabs")
		if ok then
			tabs_mod = mod
		end
	end
	if type(tabs_mod) ~= "table" or type(tabs_mod.set_title) ~= "function" then
		return nil
	end
	return tabs_mod.set_title(tab, hover)
end

-- 当前有没有活动的 tabline 扩展。
-- 与 tab 内容有关：扩展会临时深合并 sections（例如 smart_workspace_switcher 的浮层把
-- sections.tab_active / tab_inactive 换成空表，tabline 的 tabs() 于是返回空列表）。
-- tab 渲染缓存看不到这个状态，所以要靠它决定绕不绕缓存（见 style/tabline/collapse.lua）。
-- 拿不到插件模块时返回 nil，调用方按"不知道"处理。
---@return boolean|nil
function M.extensions_active()
	if not extension_mod then
		local ok, mod = pcall(require, "tabline.extension")
		if ok then
			extension_mod = mod
		end
	end
	if type(extension_mod) ~= "table" or type(extension_mod.extensions) ~= "table" then
		return nil
	end
	return #extension_mod.extensions > 0
end

-- 测宽用的 tabline.component（拿不到返回 nil）
function M.component()
	if not component_mod then
		local ok, c = pcall(require, "tabline.component")
		if ok then
			component_mod = c
		end
	end
	return component_mod
end

-- 标签两端 powerline 箭头 glyph。tabs.lua 的命名反直觉（末尾插的是 left），
-- 这里按 left/right 原样返回；插件配置成单个 glyph 时两边返回同一个值。
function M.tab_separators()
	local c = M.config()
	local seps = c and c.opts and c.opts.options and c.opts.options.tab_separators
	if type(seps) == "table" then
		return seps.left, seps.right
	end
	return seps, seps
end

-- 插件调色板（colors.normal_mode.b.fg 等）
function M.colors()
	local c = M.config()
	return c and c.colors or nil
end

-- 模式端头背景色：右状态隐藏时整行填色用（与 tab 端头同源）
function M.bar_bg()
	local colors = M.colors()
	local c = colors and colors.normal_mode and colors.normal_mode.c
	return c and c.bg or nil
end

-- sections 读取。注意 sections 是插件全局表、所有窗口共用，按窗口隐藏某一段必须走
-- 下面的 guard_section（写这张表只能做全局改动）
function M.sections()
	local c = M.config()
	return c and c.sections or nil
end

function M.get_section(name)
	local s = M.sections()
	return s and s[name]
end

-- 给某个 section 的每个组件挂一个 per-window 的 cond：插件渲染时会用当前 window
-- 调用 cond，**返回 true 才渲染**、false 的组件不输出（见 tabline util.extract_components
-- 的 `if opts.cond and not opts.cond(object) then return end`）。所以 predicate 就是 cond
-- 本身、语义是"可见"而不是"隐藏"——写成"是否该隐藏"会让显隐整个反过来。
-- sections 表是全局共享的，但 cond 按窗口求值，所以多窗口下各窗口可以独立隐藏该段
-- ——不需要每 tick 跟 tabline 抢 set_right_status。
-- 返回 guarded, total（section 不存在或为空时返回 nil）。
local GUARD_MARK = "__tabline_section_guard"
local guarded_functions = setmetatable({}, { __mode = "k" }) -- 函数组件没有属性，用弱表记

function M.guard_section(name, visible)
	local list = M.get_section(name)
	if type(list) ~= "table" or #list == 0 then
		return nil
	end
	local guarded, total = 0, 0
	for i = 1, #list do
		local entry = list[i]
		local kind = type(entry)
		total = total + 1
		if kind == "string" then
			list[i] = { entry, [GUARD_MARK] = true, cond = visible }
			guarded = guarded + 1
		elseif kind == "table" and (type(entry[1]) == "string" or entry.cond ~= nil) then
			if not entry[GUARD_MARK] then
				local prev = entry.cond
				entry[GUARD_MARK] = true
				entry.cond = prev and function(window, ...)
					return prev(window, ...) and visible(window)
				end or visible
			end
			guarded = guarded + 1
		elseif kind == "function" then
			if not guarded_functions[entry] then
				local render = entry
				local wrapper = function(window, ...)
					if not visible(window) then
						return ""
					end
					return render(window, ...)
				end
				guarded_functions[wrapper] = true
				list[i] = wrapper
			end
			guarded = guarded + 1
		end
	end
	return guarded, total
end

return M
