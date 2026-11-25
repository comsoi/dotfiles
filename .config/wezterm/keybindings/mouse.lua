local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

M.mouse_bindings = {
	{
		-- right clink select (not wezterm copy mode),copy, and if don't select anything, paste
		-- https://github.com/wez/wezterm/discussions/3541#discussioncomment-5633570
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(
					act({
						PasteFrom = "Clipboard",
					}),
					pane
				)
			end
		end),
	},
	-- Change the default click behavior so that it only selects
	-- text and doesn't open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		-- action = act.CompleteSelection('ClipboardAndPrimarySelection'),
		action = act.Nop,
	},
	-- and make CTRL-Click open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},

	-- 固定每格 5 行。wezterm 内置默认是 ScrollByCurrentEventWheelDelta，按事件携带的
	-- delta 滚：Wayland 下 axis value 会被乘上屏幕缩放（wezterm#3142，Hyprland 2x 缩放下
	-- 一格 = 30 行），高分辨率/平滑滚轮还会更大，一次能翻大半屏。
	-- alt_screen = false：本绑定只在普通屏幕生效；alt screen（nvim/less 等）里由 wezterm
	-- 内置把滚轮映射成方向键（alternate_buffer_wheel_scroll_speed，默认 3 行），不写这个
	-- 字段会导致全屏应用里滚轮失效（见 wezterm#3142 hexchain 的评论、#6922 wez 的回复）。
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "NONE",
		alt_screen = false,
		action = act.ScrollByLine(-5),
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "NONE",
		alt_screen = false,
		action = act.ScrollByLine(5),
	},

	-- Scrolling up while holding CTRL increases the font size
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "CTRL",
		action = act.IncreaseFontSize,
	},

	-- Scrolling down while holding CTRL decreases the font size
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "CTRL",
		action = act.DecreaseFontSize,
	},
	{
		event = { Down = { streak = 4, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
}

function M.apply(config)
	config.mouse_bindings = M.mouse_bindings
end

return M
