-- tab_title.lua
local M = {}

-- 判断字符串是否为路径
local function is_path(str)
	if not str or str == "" then
		return false
	end

	-- 移除引号
	str = str:gsub('^"(.*)"$', "%1")
	str = str:gsub("^'(.*)'$", "%1")

	-- 替换转义的空格
	str = str:gsub("\\ ", " ")

	-- 检查常见路径起始
	local first_char = str:sub(1, 1)
	if first_char == "/" or first_char == "~" then
		return true
	end

	-- 检查 Windows 盘符路径 (如 C:/, D:\)
	if str:match("^%a:[/\\]") then
		return true
	end

	-- 检查相对路径起始
	if str:match("^%.%.?[/\\]") then
		return true
	end

	-- 检查是否包含路径分隔符
	return str:find("[/\\]") ~= nil
end

-- 分割命令行参数，保持引号内的空格
local function split_args(str)
	local args = {}
	local current_arg = ""
	local in_quotes = false
	local quote_char = nil
	local escaped = false
	local i = 1

	while i <= #str do
		local char = str:sub(i, i)

		-- 处理转义字符
		if char == "\\" and not escaped then
			escaped = true
			i = i + 1
			goto continue
		end

		-- 处理引号
		if (char == '"' or char == "'") and not escaped then
			if not in_quotes then
				in_quotes = true
				quote_char = char
			elseif char == quote_char then
				in_quotes = false
				quote_char = nil
			else
				current_arg = current_arg .. char
			end
			-- 处理空格
		elseif char == " " and not in_quotes then
			if #current_arg > 0 then
				table.insert(args, current_arg)
				current_arg = ""
			end
			-- 处理其他字符
		else
			if escaped and char ~= quote_char then
				current_arg = current_arg .. "\\"
			end
			current_arg = current_arg .. char
		end

		escaped = false
		i = i + 1
		::continue::
	end

	-- 处理未闭合的引号
	if in_quotes then
		current_arg = quote_char .. current_arg
	end

	-- 处理最后一个参数
	if #current_arg > 0 then
		table.insert(args, current_arg)
	end

	return args
end

local function abbreviate_path(path, max_length)
	-- 参数校验
	if not path or not max_length then
		return path
	end

	-- 常量定义
	local ELLIPSIS = "..."
	local SEP = "/"
	local MIN_LENGTH = 2 -- 路径段的最小保留长度

	-- 预处理路径
	path = path:gsub('^"(.+)"$', '%1') -- 移除包围的引号
	path = path:gsub([[\]], "/")       -- 统一路径分隔符
	path = path:gsub([[\ ]], " ")      -- 处理转义空格

	-- 快速路径：如果路径已经足够短，直接返回
	if #path <= max_length then
		return path
	end

	-- 处理主目录路径
	local home = os.getenv("HOME") or ""
	if home ~= "" then
		local escaped_home = "^" .. home:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
		path = path:gsub(escaped_home, "~")
	end

	-- 解析路径特征
	local is_absolute = path:sub(1, 1) == "/"
	local parts = {}
	for part in string.gmatch(path, "[^/]+") do
		table.insert(parts, part)
	end

	-- 处理空路径或单段路径
	if #parts == 0 then
		return is_absolute and "/" or ""
	elseif #parts == 1 then
		local max_part_len = max_length - (is_absolute and 1 or 0)
		return (is_absolute and "/" or "") .. parts[1]:sub(1, max_part_len)
	end

	-- 辅助函数：重建完整路径
	local function build_path(segments)
		return (is_absolute and "/" or "") .. table.concat(segments, "/")
	end

	-- 首字母缩写策略
	local function get_abbreviation(segment)
		return segment:sub(1, 1)
	end

	-- 缩短路径的主要逻辑
	local function shorten_path()
		-- 如果只有两段，特殊处理
		if #parts == 2 then
			local available = max_length - (is_absolute and 1 or 0) - 1 -- 减去分隔符
			local each_len = math.floor(available / 2)
			local first = parts[1]:sub(1, each_len)
			local second = parts[2]:sub(1, available - each_len)
			return (is_absolute and "/" or "") .. first .. "/" .. second
		end

		-- 创建工作副本
		local result = {}
		for i = 1, #parts do
			result[i] = parts[i]
		end

		-- 第一步：将中间段缩写为首字母
		for i = 2, #parts - 1 do
			result[i] = get_abbreviation(parts[i])
		end

		-- 检查是否满足长度要求
		local path = build_path(result)
		if #path <= max_length then
			return path
		end

		-- 第二步：如果需要，缩短尾部
		if #result[#result] > MIN_LENGTH then
			result[#result] = result[#result]:sub(1, MIN_LENGTH)
			path = build_path(result)
			if #path <= max_length then
				return path
			end
		end

		-- 第三步：如果需要，缩短首部
		if #result[1] > MIN_LENGTH then
			result[1] = result[1]:sub(1, MIN_LENGTH)
			path = build_path(result)
			if #path <= max_length then
				return path
			end
		end

		-- 最后的后备方案：使用省略号
		local final_result = ""
		if is_absolute then
			final_result = "/"
		end
		final_result = final_result .. result[1]:sub(1, MIN_LENGTH) .. "/" .. ELLIPSIS .. "/"

		local remaining = max_length - #final_result
		if remaining > 0 then
			final_result = final_result .. parts[#parts]:sub(1, remaining)
		end

		return final_result
	end

	return shorten_path()
end

-- 处理单个参数
local function process_argument(arg, max_length)
	-- 检查是否为路径
	if is_path(arg) then
		return abbreviate_path(arg, max_length)
	else
		-- 非路径参数，如果超长则截断
		if #arg > max_length then
			return arg:sub(1, max_length - 1) .. "∷"
		else
			return arg
		end
	end
end

-- 缩写标题的函数
-- lua
function M.abbreviate_title(title)
	local max_length = 25
	if #title <= max_length then
		return title
	end

	local args = split_args(title)
	if #args == 0 then
		return title
	end

	if #args == 1 then
		return process_argument(args[1], max_length)
	end

	local cmd_length = 8
	local shortened_cmd = args[1]:sub(1, cmd_length)
	local remaining_length = max_length - cmd_length - 1

	if #args == 2 then
		return shortened_cmd .. " " .. process_argument(args[2], remaining_length)
	end

	-- 处理多个参数
	local space = " "
	local arg_count = #args - 1
	local min_arg_length = 4
	local displayable_args = math.floor(remaining_length / min_arg_length)
	displayable_args = math.min(displayable_args, arg_count)

	local arg_length = math.floor(remaining_length / displayable_args)
	local processed_args = {}

	for i = 2, displayable_args + 1 do
		table.insert(processed_args, process_argument(args[i], arg_length))
	end

	local result = shortened_cmd .. space .. table.concat(processed_args, space)
	if displayable_args < arg_count then
		result = result .. "∷"
	end

	if #result > max_length then
		if max_length > 3 then
			result = result:sub(1, max_length - 1) .. "%"
		else
			result = string.rep(".", max_length)
		end
	end

	return result
end

-- 允许设置最大长度
function M.set_max_length(length)
	M.max_length = length
end

return M

-- 测试用例
-- print("Test 1:", M.abbreviate_title("vim /usr/share/etc/nginx/nginx.conf"))
-- print("Test 2:", M.abbreviate_title("vim /usr/local/bin/python3 /etc/nginx/nginx.conf"))
-- print("Test 3:", M.abbreviate_title("vim /very/long/path/to/some/file/that/is/deep/in/filesystem.txt"))
-- print("Test 4:", M.abbreviate_title("cp /usr/share/doc/python3/examples/scripts/long_script_name.py /home/user/dest.py"))
-- print("Test 5:", M.abbreviate_title("/usr/local/bin/very/long/path/executable"))
-- print("Test 6:", M.abbreviate_title("vim /etc/systemd/system/very-long-service-name.service"))
-- print("Test 7:", M.abbreviate_title("/usr/share/nginx/html/index.html"))
-- print("Test 8:", M.abbreviate_title("vim /var/log/very/long/path/error.log"))
-- print("Test 9:", M.abbreviate_title("vim /var/log/very/long/path/a/s/d/error.log"))
-- print("Test 0:", M.abbreviate_title('git commit -m "very long message" --amend --no-verify'))
