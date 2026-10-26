---------------------
-- Window binds    --
---------------------

-- Kill window
hypr.bind.leader_key("Q", hl.dsp.window.close())
hypr.bind.leader_key("SHIFT + Q", hl.dsp.window.kill())

-- Fullscreen
hypr.bind.leader_key("F", hl.dsp.window.fullscreen_state({ internal = 2, client = 1, action = "toggle" }))
hypr.bind.leader_key("CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hypr.bind.leader_key("SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hypr.bind.leader_key("page_up", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hypr.bind.leader_key("page_down", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Focus (vim keys)
hypr.bind.leader_key("H", hl.dsp.focus({ direction = "left" }))
hypr.bind.leader_key("L", hl.dsp.focus({ direction = "right" }))
hypr.bind.leader_key("K", hl.dsp.focus({ direction = "up" }))
hypr.bind.leader_key("J", hl.dsp.focus({ direction = "down" }))

-- Focus (arrow keys)
hypr.bind.leader_key("left", hl.dsp.focus({ direction = "left" }))
hypr.bind.leader_key("right", hl.dsp.focus({ direction = "right" }))
hypr.bind.leader_key("up", hl.dsp.focus({ direction = "up" }))
hypr.bind.leader_key("down", hl.dsp.focus({ direction = "down" }))

-- Mouse wheel focus
hypr.bind.leader_key("mouse_up", hl.dsp.focus({ direction = "left" }))
hypr.bind.leader_key("mouse_down", hl.dsp.focus({ direction = "right" }))

-- Mouse drag / resize
hypr.bind.leader_key("mouse:272", hl.dsp.window.drag(), { mouse = true })
hypr.bind.leader_key("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move windows (vim keys)
hypr.bind.leader_key("CTRL + H", hl.dsp.window.move({ direction = "l" }))
hypr.bind.leader_key("CTRL + L", hl.dsp.window.move({ direction = "r" }))
hypr.bind.leader_key("CTRL + K", hl.dsp.window.move({ direction = "u" }))
hypr.bind.leader_key("CTRL + J", hl.dsp.window.move({ direction = "d" }))

-- Swap windows (vim keys)
hypr.bind.leader_key("ALT + H", hl.dsp.window.swap({ direction = "l" }))
hypr.bind.leader_key("ALT + L", hl.dsp.window.swap({ direction = "r" }))
hypr.bind.leader_key("ALT + K", hl.dsp.window.swap({ direction = "u" }))
hypr.bind.leader_key("ALT + J", hl.dsp.window.swap({ direction = "d" }))

-- Resize windows (vim keys)
hypr.bind.leader_key("SHIFT + L", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hypr.bind.leader_key("SHIFT + H", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hypr.bind.leader_key("SHIFT + J", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hypr.bind.leader_key("SHIFT + K", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))

-- Resize windows (arrow keys)
hypr.bind.leader_key("SHIFT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hypr.bind.leader_key("SHIFT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hypr.bind.leader_key("SHIFT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hypr.bind.leader_key("SHIFT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))

-- Swap workspaces between monitors
hypr.bind.leader_key("grave", hl.dsp.workspace.swap_monitors({ monitor1 = "HDMI-A-1", monitor2 = "eDP-1" }))
hypr.bind.leader_key("grave", hl.dsp.workspace.swap_monitors({ monitor1 = "DP-1", monitor2 = "eDP-1" }))

-- Cycle / bring to top
hl.bind("ALT + grave", hl.dsp.window.cycle_next())
hl.bind("ALT + grave", hl.dsp.window.alter_zorder({ mode = "top" }))

-- Group management (dwindle only)
hypr.bind.leader_key("G", hypr.dsp.layout({ dwindle = hl.dsp.group.toggle() }))
hypr.bind.leader_key("J", hypr.dsp.layout({ dwindle = hl.dsp.group.next() }))
hypr.bind.leader_key("K", hypr.dsp.layout({ dwindle = hl.dsp.group.prev() }))

-- Pin
hypr.bind.leader_key("CTRL + T", hl.dsp.window.pin())

-- Float toggle
hypr.bind.leader_key("ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hypr.bind.leader_key("T", hl.dsp.window.float({ action = "toggle" }))

-- Float all on current workspace
hypr.bind.leader_key("SHIFT + T", hypr.window.float_all)
hypr.bind.leader_key("SHIFT + P", hypr.dpms)

-- Layout messages (dwindle / scrolling)
hypr.bind.leader_key("U", hypr.dsp.layout({ dwindle = "swapsplit" }))
hypr.bind.leader_key("R", hypr.dsp.layout({
	dwindle   = "togglesplit",
	scrolling = "promote",
}))

-- Adjust split / column ratio
hypr.bind.leader_key("Minus", hypr.dsp.layout({
	dwindle   = "splitratio -0.1",
	scrolling = "colresize -0.1",
}))
hypr.bind.leader_key("Equal", hypr.dsp.layout({
	dwindle   = "splitratio +0.1",
	scrolling = "colresize +0.1",
}))

-- Pseudo tiling
hypr.bind.leader_key("I", hl.dsp.window.pseudo())
hypr.bind.leader_key("SHIFT + I", function()
	hypr.window.for_each(function(w)
		hl.dispatch(hl.dsp.window.pseudo({ window = "address:" .. w.address }))
	end)
end)

-- Show desktop
hypr.bind.leader_key("D", hypr.workspace.show_desktop)

-- Window opacity (SUPER + ALT + scroll wheel)
hypr.bind.leader_key("ALT + mouse_up", hypr.dsp.exec("~/.config/hypr/scripts/opacity.sh 0.05"))
hypr.bind.leader_key("ALT + mouse_down", hypr.dsp.exec("~/.config/hypr/scripts/opacity.sh -0.05"))

-- Cursor zoom
hypr.bind.leader_key("CTRL + mouse_down", function()
	local z = hl.get_config("cursor:zoom_factor")
	hl.config({ cursor = { zoom_factor = z * 1.2 } })
end, { repeating = true })
hypr.bind.leader_key("CTRL + mouse_up", function()
	local z = hl.get_config("cursor:zoom_factor")
	hl.config({ cursor = { zoom_factor = math.max(z * 0.9, 1) } })
end, { repeating = true })

-------------------------
-- Workspace binds     --
-------------------------

-- Workspace switcher overlay (bindit equivalent)
hl.bind("Super_L", hl.dsp.global("quickshell:workspaceNumber"))
hl.bind("Super_R", hl.dsp.global("quickshell:workspaceNumber"))

-- Switch / move to workspace 1-10
for i = 1, 10 do
	local key = i % 10
	hypr.bind.leader_key("" .. key, hl.dsp.focus({ workspace = i }))
	hypr.bind.leader_key("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hypr.bind.leader_key("CTRL + " .. key, function()
		hypr.window.move_all_to(i)
	end)
end

-- Workspace navigation
hypr.bind.leader_key("End", hl.dsp.focus({ workspace = "+1" }))
hypr.bind.leader_key("Home", hl.dsp.focus({ workspace = "m-1" }))
hypr.bind.leader_key("Tab", hl.dsp.focus({ workspace = "m+1" }))
hypr.bind.leader_key("SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))

-- Mouse workspace scroll
hypr.bind.leader_key("SHIFT + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hypr.bind.leader_key("SHIFT + mouse_up", hl.dsp.focus({ workspace = "m-1" }))

-- Ctrl + arrow workspace navigation
hypr.bind.leader_key("CTRL + down", hl.dsp.focus({ workspace = "m-1" }))
hypr.bind.leader_key("CTRL + up", hl.dsp.focus({ workspace = "m+1" }))
hypr.bind.leader_key("CTRL + left", hl.dsp.focus({ workspace = "e-1" }))
hypr.bind.leader_key("CTRL + right", hl.dsp.focus({ workspace = "e+1" }))

hypr.bind.leader_key("SHIFT + CTRL + down", hl.dsp.window.move({ workspace = "m-1" }))
hypr.bind.leader_key("SHIFT + CTRL + up", hl.dsp.window.move({ workspace = "m+1" }))
hypr.bind.leader_key("SHIFT + CTRL + left", hl.dsp.window.move({ workspace = "e-1" }))
hypr.bind.leader_key("SHIFT + CTRL + right", hl.dsp.window.move({ workspace = "e+1" }))

-- Special workspaces
for i = 1, 5 do
	local key = i % 10
	hypr.bind.leader_key("" .. "F" .. key, hl.dsp.workspace.toggle_special("w" .. i))
	hypr.bind.leader_key("SHIFT + " .. "F" .. key, hl.dsp.window.move({ workspace = "special:w" .. i }))
end

hypr.bind.leader_key("X", hl.dsp.workspace.toggle_special("special"))
hypr.bind.leader_key("SHIFT + X", hl.dsp.window.move({ workspace = "special:special" }))
