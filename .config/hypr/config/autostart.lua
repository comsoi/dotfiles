-- Autostart and shutdown commands

local M = {}

function M.apply(cfg)
	local startup = {
		-- inputactions config symlink
		"ln -srf ~/.config/inputactions/config_hyprland.yaml ~/.config/inputactions/config.yaml",
		-- Night Light
		'echo "hyprsunset" > ~/.local/state/sunsetr/default/active_preset',
		-- Wallpaper (waypaper)
		"waypaper --restore",
		-- KDE dialogs for qt6ct
		"crudini --set ~/.config/qt6ct/qt6ct.conf Appearance standard_dialogs kde",
		-- Load Xresources
		"xrdb -merge ~/.config/.Xresources",
		-- Load cliphist history
		"runapp -i background.slice -- wl-paste --watch cliphist store",
		-- ALT-TAB (hyprshell)
		"runapp -i background-graphical.slice -- hyprshell run",
		-- Quick Settings overview
		"runapp -i background-graphical.slice -- qs -c overview",
		-- OSD
		"runapp -i background-graphical.slice -- swayosd-server",
		-- input switcher
		"runapp -i background-graphical.slice -- hypr-input-switcher",
		-- Workspace init: launch zen-browser on ws2, kitty on ws1
		"[workspace 2 silent] runapp -o -- zen-browser",
		"[workspace 1 silent] runapp -o -- kitty -1",
	}

	hl.on("hyprland.start", function()
		for _, cmd in ipairs(startup) do
			hypr.exec(cmd)
		end

		-- Systemd inhibit for power key (wleave keybind)
		if os.getenv("XDG_RUNTIME_DIR") then
			hypr.exec('systemd-inhibit --who="Hyprland config" --why="wleave keybind" --what=handle-power-key --mode=block sleep infinity & echo $! > $XDG_RUNTIME_DIR/.hyprland-systemd-inhibit')
		end
	end)

	-- Shutdown: kill systemd-inhibit
	hl.on("hyprland.shutdown", function()
		if os.getenv("XDG_RUNTIME_DIR") then
			hypr.exec('kill -9 "$(cat $XDG_RUNTIME_DIR/.hyprland-systemd-inhibit)" && rm "$XDG_RUNTIME_DIR/.hyprland-systemd-inhibit"')
		end
	end)
end

return M
