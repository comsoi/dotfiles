-- Config module: defaults, derive, setup

local Utils = require("lib.utils")

local config = {}

config.defaults = {
	mainMod  = "SUPER",
	nvidia   = { enable = nil },

	app = {
		term     = nil,
		term_cmd = nil,
		menu     = "rofi",
		menu_cmd = nil,
		dmenu_cmd = nil,
	},

	input      = require("config.input"),
	decoration = require("config.decoration"),
	layout     = require("config.layout"),
	misc       = require("config.misc"),
	monitors   = require("config.monitors"),
	gestures   = require("config.gestures"),
	autostart   = require("config.autostart"),
	animations  = require("config.animations"),
	keybindings = require("config.keybindings"),
	rules       = require("config.rules"),
	plugins     = require("config.plugins"),
}

local function derive(cfg)
	if cfg.app.term == nil then
		cfg.app.term = Utils.detect_term()
	end
	if cfg.app.term_cmd == nil then
		cfg.app.term_cmd = Utils.term_cmds[cfg.app.term] or cfg.app.term
	end

	if cfg.nvidia.enable == nil then
		cfg.nvidia.enable = Utils.has_nvidia_gpu()
	end

	if cfg.app.menu_cmd == nil then
		cfg.app.menu_cmd = cfg.app.menu .. " -name rofiMenu"
	end
	if cfg.app.dmenu_cmd == nil then
		cfg.app.dmenu_cmd = cfg.app.menu .. " -name rofiDmenu -i -dmenu"
	end

	Utils.resolve_globals(cfg)
end

config.setup = function(overrides)
	local cfg = Utils.deep_extend({}, config.defaults)
	if overrides then Utils.deep_extend(cfg, overrides) end
	derive(cfg)

	config.mainMod = cfg.mainMod  -- api.lua compat

	cfg.input.apply(cfg)
	cfg.decoration.apply(cfg)
	cfg.layout.apply(cfg)
	cfg.misc.apply(cfg)
	cfg.monitors.apply(cfg)
	cfg.gestures.apply(cfg)

	cfg.autostart.apply(cfg)
	cfg.animations.apply(cfg)
	cfg.keybindings.apply(cfg)
	cfg.rules.apply(cfg)
	cfg.plugins.apply(cfg)
	if cfg.nvidia.enable and Utils.has_external_monitor() then
		hl.config({ cursor = { no_hardware_cursors = true } })
	end
end

return config
