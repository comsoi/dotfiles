local wezterm = require("wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local M = {}

function M.apply(config) -- config 未使用，签名与其它 style 模块保持一致
	workspace_switcher.workspace_formatter = function(label)
		return wezterm.format({
			{ Attribute = { Italic = true } },
			{ Text = wezterm.nerdfonts.cod_terminal_tmux .. " " .. string.match(label, "[^/\\]+$") },
		})
	end
end

return M
