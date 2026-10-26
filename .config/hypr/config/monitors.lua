local M    = {}

M.monitors = {
	internal = {
		output   = "eDP-1",
		mode     = "2560x1600@165",
		scale    = 1.6,
		-- bitdepth = 10,
	},
	xiaomi = {
		output   = "desc:Xiaomi Corporation P27QBA-RA 4790610007716",
		mode     = "2560x1440@75.03Hz",
		scale    = 1,
	},
	huawei = {
		output   = "desc:Huawei Technologies Co. Inc. SSN-24",
		mode     = "1920x1080",
		scale    = 1,
	},
	lecoo = {
		output   = "desc:Lectron Company Ltd LECOO B2413E 00000021",
		mode     = "1920x1080@74.97",
		scale    = 1,
	},
}

M.scenarios = {
	home = {
		internal = { position = "auto-left" },
		xiaomi   = { position = "0x0" },
	},
	work = {
		internal = { position = "0x0" },
		huawei   = { position = "auto-left" },
	},
	mobile = {
		internal = {},
	},
}

-- 仅内置屏幕时，workspace 1 强制 dwindle 布局
M.ws1_dwindle = hl.workspace_rule({ workspace = "1", layout = "dwindle" })


function M.apply(cfg)
	local scenario = cfg.monitors.scenario
	if not scenario then return end
	local monitors = M.scenarios[scenario]

	local function init()
		for key, overrides in pairs(monitors) do
			local mon = M.monitors[key]
			if mon then
				hl.monitor({
					output   = mon.output,
					mode     = mon.mode,
					scale    = mon.scale,
					bitdepth = mon.bitdepth,
					position = overrides.position or mon.position,
				})
			end
		end

		-- 仅内置屏幕时强制 workspace 1 使用 dwindle
		M.ws1_dwindle:set_enabled(not utils.has_external_monitor())
	end

	init()

	hl.on("monitor.layout_changed", init)
end

return M
