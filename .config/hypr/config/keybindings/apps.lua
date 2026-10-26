--------------------------
-- Application launchers --
--------------------------

-- Browser
hypr.bind.leader_key("B", hypr.dsp.launch("zen-browser.desktop"))
hypr.bind.leader_key("ALT + B", hypr.dsp.exec("uwsm-app -- google-chrome-stable"))

-- Editor
hypr.bind.leader_key("C", hypr.dsp.launch("code.desktop"))

-- File Manager
hypr.bind.leader_key("E", hypr.dsp.exec("gapplication launch org.gnome.Nautilus"))
hypr.bind.leader_key("SHIFT + E", hypr.dsp.launch("org.kde.dolphin.desktop"))

-- Emoji picker / Calculator
hypr.bind.leader_key("CTRL + E", hypr.dsp.launch("it.mijorus.smile.desktop"))
hypr.bind.leader_key("CTRL + C", hypr.dsp.launch("org.gnome.Calculator.desktop"))

-- Fn key apps
hl.bind("XF86Calculator", hypr.dsp.launch("org.gnome.Calculator.desktop"))
hl.bind("XF86Tools", hypr.dsp.launch("Alacritty.desktop"))

-- Terminals
hypr.bind.leader_key("RETURN", hypr.dsp.exec("uwsm-app -- kitty -1"))
hypr.bind.leader_key("SHIFT + Return", hypr.dsp.launch("com.mitchellh.ghostty.desktop"))
hypr.bind.leader_key("SHIFT + CTRL + Return", hypr.dsp.launch("org.wezfurlong.wezterm.desktop"))
hl.bind("CTRL + ALT + T", hypr.dsp.exec("uwsm-app -- alacritty-sock.sh"))

-- Wayscriber (screenshot OCR)
hypr.bind.leader_key("ALT + D", hypr.dsp.exec("pkill -SIGUSR1 wayscriber"))

-- Ghostty quake mode
-- 已禁用：CTRL+grave 让给 kitty 里的 nvim（Snacks.terminal("zsh")，见 nvim lua/config/keymaps.lua）
-- hl.bind("CTRL + grave", hl.dsp.global("com.mitchellh.ghostty:CTRL+grave"))
