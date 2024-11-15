-- tab_title.lua
local M = {}

-- 判断字符串是否为路径
local function is_path(str)
    -- 移除引号
    str = str:gsub('^"(.*)"$', '%1')
    str = str:gsub("^'(.*)'$", '%1')

    -- 替换转义的空格
    str = str:gsub('\\ ', ' ')

    -- 检查是否以 / 或 ~ 开头
    if str:sub(1, 1) == "/" or str:sub(1, 1) == "~" then
        return true
    end

    -- 检查是否包含路径分隔符
    if str:find("/") then
        return true
    end

    -- 检查是否是相对路径（以 . 或 .. 开头）
    if str:match("^%.") or str:match("^%.%.") then
        return true
    end

    return false
end

-- 分割命令行参数，保持引号内的空格
local function split_args(str)
    local args = {}
    local current_arg = ""
    local in_quotes = false
    local quote_char = nil
    local i = 1

    while i <= #str do
        local char = str:sub(i, i)

        if (char == '"' or char == "'") and (i == 1 or str:sub(i - 1, i - 1) ~= "\\") then
            if not in_quotes then
                in_quotes = true
                quote_char = char
            elseif char == quote_char then
                in_quotes = false
                quote_char = nil
            else
                current_arg = current_arg .. char
            end
        elseif char == " " and not in_quotes then
            if #current_arg > 0 then
                table.insert(args, current_arg)
                current_arg = ""
            end
        else
            current_arg = current_arg .. char
        end

        i = i + 1
    end

    if #current_arg > 0 then
        table.insert(args, current_arg)
    end

    return args
end

-- 智能缩写路径
local function abbreviate_path(path, max_length)
    -- 预处理路径
    path = path:gsub('^"(.*)"$', '%1')
    path = path:gsub("^'(.*)'$", '%1')
    path = path:gsub('\\ ', ' ')

    -- 如果路径已经足够短，直接返回
    if #path <= max_length then
        return path
    end

    -- 检查是否是绝对路径或主目录路径
    local is_absolute = path:sub(1, 1) == "/"
    local has_home = path:sub(1, 1) == "~"

    -- 处理主目录路径
    local home = os.getenv("HOME") or ""
    if home ~= "" and path:find("^" .. home) then
        path = "~" .. path:sub(#home + 1)
        has_home = true
        is_absolute = false
    end

    -- 分割路径
    local parts = {}
    for part in path:gmatch("[^/]+") do
        table.insert(parts, part)
    end

    -- 如果只有一个部分，直接截断
    if #parts <= 1 then
        return path:sub(1, max_length - 2) .. ".."
    end

    -- 路径缩写策略
    local shortened = false

    -- 1. 尝试保留第一部分和最后两部分，中间用...代替
    if #parts > 3 then
        local first = parts[1]
        local last1 = parts[#parts - 1]
        local last = parts[#parts]
        local abbr = (is_absolute and "/" or "") .. first .. "/.../" .. last1 .. "/" .. last

        if #abbr <= max_length then
            return abbr
        end

        -- 2. 只保留第一部分和最后一部分
        abbr = (is_absolute and "/" or "") .. first .. "/../" .. last
        if #abbr <= max_length then
            return abbr
        end
    end

    -- 3. 缩短中间的部分（保留开头和结尾）
    local mid_start = 2
    local mid_end = #parts - 1
    local min_segment_length = 1

    while not shortened and mid_start <= mid_end do
        for i = mid_start, mid_end do
            if #parts[i] > min_segment_length then
                parts[i] = parts[i]:sub(1, min_segment_length)
                shortened = true
            end
        end
        min_segment_length = min_segment_length - 1
        if min_segment_length < 1 then break end
    end

    -- 4. 如果还是太长，使用最简单的缩写形式
    local result = table.concat(parts, "/")
    if is_absolute then
        result = "/" .. result
    end

    if #result > max_length then
        -- 保留开头和结尾的重要部分
        local first_part = parts[1]
        local last_part = parts[#parts]
        result = (is_absolute and "/" or "") .. first_part .. "/../" .. last_part

        -- 如果还是太长，就只保留最后一部分
        if #result > max_length then
            result = ".../" .. last_part
        end
    end

    return result
end

-- 处理单个参数
local function process_argument(arg, max_length)
    -- 检查是否为路径
    if is_path(arg) then
        return abbreviate_path(arg, max_length)
    else
        -- 非路径参数，如果超长则截断
        if #arg > max_length then
            return arg:sub(1, max_length - 2) .. ".."
        else
            return arg
        end
    end
end

-- 缩写标题的函数
function M.abbreviate_title(title)
    local max_length = 25
    if #title <= max_length then
        return title
    end

    -- 分割命令行参数
    local args = split_args(title)
    if #args == 0 then
        return title
    end

    -- 优先确保命令名称可读
    local cmd_length = math.min(#args[1], 8)             -- 命令名最多保留8个字符
    local remaining_length = max_length - cmd_length - 1 -- 减去空格

    -- 如果只有命令，没有参数
    if #args == 1 then
        return process_argument(args[1], max_length)
    end

    -- 处理命令和参数
    local result = args[1]:sub(1, cmd_length)

    -- 处理剩余参数
    if #args == 2 then
        -- 只有一个参数时，给它分配所有剩余空间
        local processed_arg = process_argument(args[2], remaining_length)
        return result .. " " .. processed_arg
    else
        -- 多个参数时，只显示第一个参数的缩写
        local first_arg = process_argument(args[2], remaining_length - 3) -- 为"..."预留空间
        return result .. " " .. first_arg .. "..."
    end
end

-- 允许设置最大长度
function M.set_max_length(length)
    M.max_length = length
end

return M

-- 测试用例
-- print("Test 1:", abbreviate_title("vim /usr/share/etc/nginx/nginx.conf"))
-- print("Test 2:", abbreviate_title("vim /usr/local/bin/python3 /etc/nginx/nginx.conf"))
-- print("Test 3:", abbreviate_title("vim /very/long/path/to/some/file/that/is/deep/in/filesystem.txt"))
-- print("Test 4:", abbreviate_title("cp /usr/share/doc/python3/examples/scripts/long_script_name.py /home/user/dest.py"))
-- print("Test 5:", abbreviate_title("/usr/local/bin/very/long/path/executable"))
-- print("Test 6:", abbreviate_title("vim /etc/systemd/system/very-long-service-name.service"))
-- print("Test 7:", abbreviate_title("/usr/share/nginx/html/index.html"))
-- print("Test 8:", abbreviate_title("vim /var/log/very/long/path/error.log"))
