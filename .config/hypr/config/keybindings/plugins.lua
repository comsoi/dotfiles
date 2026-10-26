-- Plugin keybindings
-- Split-monitor-workspaces: unbinds default workspace binds 1-9 and remaps to plugin
-- Hymission: overview / task-switcher binds with toggle-aware state

if hl.plugin.split_monitor_workspaces ~= nil then
	local smw = hl.plugin.split_monitor_workspaces
	for i = 1, 10 do
		local key = i % 10
		hl.unbind(config.mainMod .. " + " .. key)
		hl.unbind(config.mainMod .. " + SHIFT + " .. key)
		hl.unbind(config.mainMod .. " + CTRL + " .. key)
		hypr.bind.leader_key("" .. key, function()
			return smw.workspace(i)
		end)
		hypr.bind.leader_key("SHIFT + " .. key, function()
			return smw.move_to_workspace(i)
		end)
		hypr.bind.leader_key("CTRL + " .. key, function()
			local windows = hl.get_active_workspace():get_windows()
			for _, w in ipairs(windows) do
				hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
				hl.plugin.split_monitor_workspaces.move_to_workspace_silent(i)
			end
			hl.plugin.split_monitor_workspaces.workspace(i)
		end)
	end
	hl.unbind(config.mainMod .. " + End")
	hypr.bind.leader_key("End", function()
		return smw.cycle_workspaces("next")
	end)
end

if hl.plugin.hymission ~= nil then
	local is_open = false

	for _, v in ipairs({
		{
			key = "A",
			func = function()
				if is_open then
					is_open = false
					hl.plugin.hymission.close()
				else
					is_open = true
					hl.plugin.hymission.open("forceall")
				end
			end,
		},
		{
			key = "W",
			func = function()
				if is_open then
					is_open = false
					hl.plugin.hymission.close()
				else
					is_open = true
					hl.plugin.hymission.open("onlycurrentworkspace")
				end
			end,
		},
	}) do
		hl.unbind(config.mainMod .. " + " .. v.key)
		hl.bind(config.mainMod .. " + " .. v.key, v.func)
	end

	hl.unbind("ALT + Tab")
	hl.bind("ALT + Tab", function()
		hl.plugin.hymission.toggle("onlycurrentworkspace")
	end)
end

-- Overview (qs)
hl.bind("SUPER + G", hypr.dsp.exec("qs ipc -c overview call overview toggle"))
