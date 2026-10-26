-----------------------
-- Utility keybindings --
-----------------------
HYPRSCRIPTS = "~/.config/hypr/scripts"

-- Notification center
hypr.bind.leader_key("V", hypr.dsp.exec("swaync-client -t"))
-- Clipboard manager
hypr.bind.leader_key("SHIFT + V", hypr.dsp.exec(HYPRSCRIPTS .. "/cliphist.sh"))

-- Logout / power menu
hypr.bind.leader_key("semicolon", hypr.dsp.exec("hyprlock"))
hypr.bind.leader_key("CTRL + Q", hypr.dsp.exec("~/.config/wleave/toggle.sh"))

-- Game mode toggle
hypr.bind.leader_key("ALT + G", hypr.gamemode)

-- Waybar
hypr.bind.leader_key("SHIFT + B", hypr.dsp.exec("systemctl --user reload waybar.service"))
hypr.bind.leader_key("CTRL + B", hypr.dsp.exec("~/.config/waybar/toggle.sh"))
hypr.bind.leader_key("SHIFT + CTRL + B", hypr.dsp.exec("~/.config/waybar/themeswitcher.sh"))

-- Rofi launcher
hypr.bind.leader_key("CTRL + RETURN", hypr.dsp.exec('pkill rofi || rofi -show drun -replace -i -run-command "uwsm-app -- {cmd}"'))
hl.bind("ALT + SPACE", hypr.dsp.exec('pkill rofi || rofi -show drun -replace -i -run-command "uwsm-app -- {cmd}"'))

-- Wallpaper
hypr.bind.leader_key("SHIFT + W", hypr.dsp.exec("waypaper --random"))
hypr.bind.leader_key("SHIFT + CTRL + W", hypr.dsp.exec("~/.config/waypaper/waypaper-random-toggle.sh"))
hypr.bind.leader_key("CTRL + W", hypr.dsp.exec("uwsm-app waypaper || waypaper"))

-- Screenshots
-- Current output (focused monitor), save + clipboard: same chord as niri / KDE Spectacle
hl.bind(
	"PRINT",
	hypr.dsp.exec(
		"grimblast --notify copysave output \"$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date '+%Y%m%d_%H%M%S').png\""
	)
)
-- Whole virtual screen (all outputs) to the clipboard, same chord as niri's Shift+Print
hl.bind("SHIFT + PRINT", hypr.dsp.exec("grimblast --notify --freeze copy screen"))
-- Active window, save + clipboard: same chord as niri / KDE Spectacle
hl.bind(
	"CTRL + PRINT",
	hypr.dsp.exec(
		"grimblast --notify copysave active \"$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date '+%Y%m%d_%H%M%S').png\""
	)
)
-- Region straight into the annotation editor (satty), parity with niri's Mod+Print
hypr.bind.leader_key("PRINT", hypr.dsp.exec("env GRIMBLAST_EDITOR='satty -f' grimblast --notify --freeze edit area"))
hypr.bind.leader_key("SHIFT + S", hypr.dsp.exec(HYPRSCRIPTS .. "/screenshot.sh"))

-- Media player (CTRL + ALT)
hl.bind("CTRL + ALT + p", hypr.media.play_pause, { locked = true })
hl.bind("CTRL + ALT + right", hypr.media.next, { locked = true })
hl.bind("CTRL + ALT + left", hypr.media.prev, { locked = true })
hl.bind("CTRL + ALT + up", hypr.media.volume_up, { locked = true, repeating = true })
hl.bind("CTRL + ALT + down", hypr.media.volume_down, { locked = true, repeating = true })

-- Snipaste
hl.bind("F1", hypr.dsp.exec("Snipaste snip"))
hl.bind("F3", hypr.dsp.exec("Snipaste paste"))

