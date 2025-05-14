local wezterm = require("wezterm")
local M = {}

function M.apply(config)
	local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
	workspace_switcher.workspace_formatter = function(label)
		return wezterm.format({
			{ Attribute = { Italic = true } },
			{ Text = wezterm.nerdfonts.cod_terminal_tmux .. " " .. string.match(label, "[^/\\]+$") },
		})
	end
end

return M
