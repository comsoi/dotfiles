-- Shared utility functions used across the configuration

local utils = {}

-- Deep extend: recursively merge source into target (mutates target)
function utils.deep_extend(target, source)
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			utils.deep_extend(target[k], v)
		elseif v ~= nil then
			target[k] = v
		end
	end
	return target
end

-- Walk a table tree and replace strings that match global variables with their values
function utils.resolve_globals(tbl, visited)
	visited = visited or {}
	if visited[tbl] then return end
	visited[tbl] = true
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			utils.resolve_globals(v, visited)
		elseif type(v) == "string" and _G[v] ~= nil then
			tbl[k] = _G[v]
		end
	end
end

-- Check if any external monitor (not eDP-1) is connected
function utils.has_external_monitor()
	for _, m in ipairs(hl.get_monitors()) do
		if m.name ~= "eDP-1" then
			return true
		end
	end
	return false
end

-- Check if NVIDIA GPU is available
function utils.has_nvidia_gpu()
	local f = io.open("/sys/module/nvidia", "r")
	if f then
		f:close()
		return true
	end
	return false
end

-- Check if a plugin is loaded (queries on each call for correctness)
function utils.is_plugin_loaded(name)
	for _, p in ipairs(hl.get_loaded_plugins()) do
		if p.name == name then
			return true
		end
	end
	return false
end

-- Detect terminal emulator from PATH
function utils.detect_term()
	local candidates = { "kitty", "foot", "ghostty", "wezterm", "alacritty", "xterm", "konsole" }
	for _, term in ipairs(candidates) do
		for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
			local f = io.open(dir .. "/" .. term, "r")
			if f then
				f:close()
				return term
			end
		end
	end
end

-- Terminal command mapping
utils.term_cmds = {
	ghostty   = "ghostty +new-window",
	foot      = "footclient",
	alacritty = "alacritty",
	kitty     = "kitty --single-instance",
	wezterm   = "wezterm start",
	xterm     = "xterm",
	konsole   = "konsole",
}

return utils
