-- Hyprland API wrappers

local hypr = {}

-- Shell command execution
function hypr.exec(cmd)
	hl.exec_cmd(cmd)
end

-- Keybinding helpers
hypr.bind = {}

function hypr.bind.leader_key(key, action, opts)
	hl.bind(config.mainMod .. " + " .. key, action, opts or {})
end

-- Dispatch helpers
hypr.dsp = {}

function hypr.dsp.exec(cmd)
	return hl.dsp.exec_cmd(cmd)
end

function hypr.dsp.launch(desktop)
	return hypr.dsp.exec("uwsm-app -- " .. desktop)
end

function hypr.dsp.layout(dispatch_table)
	local actions = {}
	for layout, action in pairs(dispatch_table) do
		actions[layout] = (type(action) == "string")
			and hl.dsp.layout(action)
			or action
	end
	return function()
		local layout = hl.get_active_workspace().tiled_layout
		if actions[layout] then
			hl.dispatch(actions[layout])
		end
	end
end

-- Media controls
hypr.media = {
	prev       = hypr.dsp.exec("swayosd-client --playerctl previous || playerctl previous"),
	next       = hypr.dsp.exec("swayosd-client --playerctl next || playerctl next"),
	play_pause = hypr.dsp.exec("swayosd-client --playerctl play-pause || playerctl play-pause"),
	stop       = hypr.dsp.exec("swayosd-client --playerctl stop || playerctl stop"),
	pause      = hypr.dsp.exec("swayosd-client --playerctl pause || playerctl pause"),
	volume_up  = hypr.dsp.exec("playerctl volume 0.1+"),
	volume_down = hypr.dsp.exec("playerctl volume 0.1-"),
}

-- Window operations
hypr.window = {}

function hypr.window.for_each(callback)
	for _, w in ipairs(hl.get_active_workspace():get_windows()) do
		callback(w)
	end
end

function hypr.window.move_all_to(ws)
	hypr.window.for_each(function(w)
		hl.dispatch(hl.dsp.window.move({
			workspace = ws,
			window = "address:" .. w.address,
		}))
	end)
end

function hypr.window.float_all()
	hypr.window.for_each(function(w)
		hl.dispatch(hl.dsp.window.float({ action = "toggle", window = "address:" .. w.address }))
	end)
end

-- DPMS with 500ms delay (prevents accidental triggers)
function hypr.dpms()
	hl.timer(function()
		hl.dispatch(hl.dsp.dpms())
	end, { timeout = 500, type = "oneshot" })
end

function hypr.gamemode()
	if hl.get_config("animations.enabled") then
		hl.config({
			animations = { enabled = false },
			decoration = {
				shadow = { enabled = false },
				blur = { enabled = false },
				fullscreen_opacity = 1,
				rounding = 0,
			},
			general = { gaps_in = 0, gaps_out = 0, border_size = 1 },
		})
		hl.animation({ leaf = "borderangle", enabled = false })
		hl.notification.create({ text = "Gamemode [ON]", timeout = 5000, color = "rgb(40a02b)" })
	else
		hypr.exec("hyprctl reload")
		hl.notification.create({ text = "Gamemode [OFF]", timeout = 5000, color = "rgb(d20f39)" })
	end
end

hypr.workspace = {}

function hypr.workspace.show_desktop()
	local ws = hl.get_active_workspace()
	local wsId = tostring(ws.id)
	local stateFile = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hyprland-show-desktop-" .. wsId

	local f = io.open(stateFile, "r")
	if f then
		local addresses = {}
		for line in f:lines() do
			if line ~= "" then table.insert(addresses, line) end
		end
		f:close()
		for _, addr in ipairs(addresses) do
			hl.dispatch(hl.dsp.window.move({ workspace = wsId, window = "address:" .. addr }))
		end
		os.remove(stateFile)
	else
		local addresses = {}
		for _, w in ipairs(ws:get_windows()) do
			table.insert(addresses, w.address)
			hl.dispatch(hl.dsp.window.move({ workspace = "special:desktop", window = "address:" .. w.address, follow = false }))
		end
		f = io.open(stateFile, "w")
		if f then
			for _, addr in ipairs(addresses) do
				f:write(addr .. "\n")
			end
			f:close()
		end
	end
end

return hypr
