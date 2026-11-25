-- cmd_abbr.lua
-- 标题缩写：压缩标题中嵌入的真实路径（fish 风格：中间段缩写为首字符，
-- 隐藏目录保留 "."，如 ~/.config/dotfiles/.config/wezterm → ~/.c/d/.c/wezterm），
-- 仍超长时按显示单元格截断。全程 UTF-8/宽字符安全，绝不产生断裂字节。

local M = {}

M.max_length = 40

-- HOME 在会话内不变，模块加载时取一次即可
local HOME = os.getenv("HOME")

-- 东亚宽字符判定（与终端单元格宽度对齐的常用区间）
local function is_wide(cp)
	return (cp >= 0x1100 and cp <= 0x115F)
		or (cp >= 0x2E80 and cp <= 0x303E)
		or (cp >= 0x3041 and cp <= 0x33FF)
		or (cp >= 0x3400 and cp <= 0x4DBF)
		or (cp >= 0x4E00 and cp <= 0x9FFF)
		or (cp >= 0xA000 and cp <= 0xA4CF)
		or (cp >= 0xAC00 and cp <= 0xD7A3)
		or (cp >= 0xF900 and cp <= 0xFAFF)
		or (cp >= 0xFE30 and cp <= 0xFE6F)
		or (cp >= 0xFF00 and cp <= 0xFF60)
		or (cp >= 0xFFE0 and cp <= 0xFFE6)
		or (cp >= 0x1F300 and cp <= 0x1FAFF)
		or (cp >= 0x20000 and cp <= 0x3FFFD)
end

local function cell_width(s)
	local w = 0
	for _, cp in utf8.codes(s) do
		w = w + (is_wide(cp) and 2 or 1)
	end
	return w
end

-- 按显示单元格截断，不会切断多字节字符
local function sub_cells(s, max_cells)
	local w, byte_end = 0, 0
	for pos, cp in utf8.codes(s) do
		local cw = is_wide(cp) and 2 or 1
		if w + cw > max_cells then
			break
		end
		w = w + cw
		byte_end = pos - 1 + #utf8.char(cp)
	end
	return s:sub(1, byte_end)
end

local function first_char(s)
	return s:match(utf8.charpattern) or ""
end

-- 判断 token 是否为真实路径（不含 scheme 判断，scheme 在 compress_path 内处理）
-- 裸相对路径要求至少三段：两段没有可压缩的中间段，且避免误伤 "and/or" 这类文本
local function is_path(s)
	if s:sub(1, 1) == "/" or s:sub(1, 2) == "~/" or s:sub(1, 2) == "./" or s:sub(1, 3) == "../" then
		return true
	end
	-- 数到第二个 "/" 即可，plain find 不产生中间字符串
	local p = s:find("/", 1, true)
	return p ~= nil and s:find("/", p + 1, true) ~= nil
end

-- fish 风格压缩单条路径；file:// 等 scheme 前缀原样保留
local function compress_path(path)
	local scheme = path:match("^(%a[%w+.-]*://)")
	if scheme then
		path = path:sub(#scheme + 1)
	end

	-- $HOME → ~（HOME 已在模块加载时缓存）
	if HOME and HOME ~= "" and (path == HOME or path:sub(1, #HOME + 1) == HOME .. "/") then
		path = "~" .. path:sub(#HOME + 1)
	end

	if #path > 1 then
		path = path:gsub("/+$", "")
	end

	local segs = {}
	for seg in (path .. "/"):gmatch("(.-)/") do
		segs[#segs + 1] = seg
	end
	if #segs <= 2 then
		return (scheme or "") .. path -- 没有可压缩的中间段
	end

	local out = {}
	for i, seg in ipairs(segs) do
		if i == 1 or i == #segs or seg == "" then
			out[i] = seg
		elseif seg:sub(1, 1) == "." and #seg > 1 then
			out[i] = "." .. first_char(seg:sub(2)) -- 隐藏目录：.config → .c
		else
			out[i] = first_char(seg)
		end
	end
	return (scheme or "") .. table.concat(out, "/")
end

function M.abbreviate_title(title)
	if not title or title == "" then
		return title
	end
	local out = title
	-- 没有 "/" 就不可能含路径，跳过逐 token 扫描
	if title:find("/", 1, true) then
		-- 压缩每个空白分隔 token 中嵌入的路径（允许括号/引号包裹）
		out = title:gsub("%S+", function(tok)
			if not tok:find("/", 1, true) then
				return tok
			end
			local lead, core, trail = tok:match("^([%(%)%[%]{}\"']*)(.-)([%(%)%[%]{}\"',;:]*)$")
			if core and core ~= "" and is_path(core) then
				return lead .. compress_path(core) .. trail
			end
			return tok
		end)
	end
	-- 单元格宽 ≤ 字节长，字节数已不超限就不必逐字符量宽
	if #out <= M.max_length then
		return out
	end
	if cell_width(out) <= M.max_length then
		return out
	end
	return sub_cells(out, math.max(M.max_length - 1, 1)) .. "…"
end

return M
