-- Pavucontrol
hl.window_rule({
    name   = "pavucontrol-float",
    match  = { class = "(.*org.pulseaudio.pavucontrol.*)" },
    float  = true,
    size   = "950 750",
    center = true,
    pin    = true,
})

-- Emoji Picker (Smile)
hl.window_rule({
    name  = "smile-float",
    match = { class = "(it.mijorus.smile)" },
    float = true,
    pin   = true,
    move  = "((monitor_w*1)-window_w-40) (90)",
})

-- Nautilus Previewer
hl.window_rule({
    name  = "nautilus-previewer-float",
    match = { class = "(org.gnome.NautilusPreviewer)" },
    float = true,
    pin   = true,
})

-- Waypaper
hl.window_rule({
    name   = "waypaper-float",
    match  = { class = "(.*waypaper.*)" },
    float  = true,
    size   = "900 700",
    center = true,
    pin    = true,
})

-- Gnome Calendar
hl.window_rule({
    name  = "gnome-calendar-float",
    match = { class = "(org.gnome.Calendar)" },
    float = true,
    pin   = true,
    size  = "450 550",
    move  = "((monitor_w*1)-window_w-16) (80)",
})

-- Mission Center
hl.window_rule({
    name   = "missioncenter-float",
    match  = { class = "(io.missioncenter.MissionCenter)" },
    float  = true,
    pin    = true,
    center = true,
    size   = "1200 800",
})

-- Mission Center Preferences
hl.window_rule({
    name   = "missioncenter-prefs-float",
    match  = { class = "(missioncenter)", title = "^(Preferences)$" },
    float  = true,
    pin    = true,
    center = true,
})

-- Clash Verge
hl.window_rule({
    name   = "clash-verge-float",
    match  = { class = "(clash-verge)" },
    float  = true,
    pin    = true,
    center = true,
    size   = "1000 700",
})

-- Clash Nyanpasu
hl.window_rule({
    name   = "clash-nyanpasu-float",
    match  = { class = "(clash-nyanpasu)" },
    float  = true,
    pin    = true,
    center = true,
    size   = "1000 700",
})

-- Gnome Calculator
hl.window_rule({
    name   = "gnome-calculator-float",
    match  = { class = "(org.gnome.Calculator)" },
    float  = true,
    size   = "700 600",
    center = true,
})

-- nwg-look
hl.window_rule({
    name  = "nwg-look-float",
    match = { class = "(nwg-look)" },
    float = true,
    size  = "700 600",
    move  = "((monitor_w*0.1)) ((monitor_h*0.2))",
})

-- Flameshot annotation window
hl.window_rule({
    name  = "flameshot-float",
    match = { class = "(flameshot)", title = "(flameshot)" },
    pin   = true,
    float = true,
})

-- WeChat: image popup
hl.window_rule({
    name     = "wechat-img-float",
    match    = { class = "^(wechat)$", initial_title = "^(图片和视频)$" },
    max_size = "1200 900",
    float    = true,
    center   = true,
})

-- WeChat: forward ("发送给") window, native Wayland title
hl.window_rule({
    name     = "wechat-forward-float",
    match    = { class = "^(wechat)$", initial_title = "^(微信发送给)$" },
    float    = true,
    center   = true,
    opaque   = true,
    no_blur  = true,
    decorate = false,
})

-- WeChat: main window (opaque, no blur, no focus, no decorate)
hl.window_rule({
    name    = "wechat-opaque",
    match   = { class = "^(wechat)$", initial_title = "^(wechat)$", float = true },
    opaque  = true,
})

hl.window_rule({
    name    = "wechat-no-blur",
    match   = { class = "^(wechat)$", initial_title = "^(wechat)$", float = true },
    no_blur = true,
})

hl.window_rule({
    name     = "wechat-no-focus",
    match    = { class = "^(wechat)$", initial_title = "^(wechat)$", float = true },
    no_focus = true,
})

hl.window_rule({
    name     = "wechat-no-decorate",
    match    = { class = "^(wechat)$", initial_title = "^(wechat)$", float = true },
    decorate = false,
})

-- MEGAsync
hl.window_rule({
    name  = "megasync-float",
    match = { class = "(nz.co.mega.megasync)" },
    float = true,
    pin   = true,
    size  = "402 560",
    move  = "((monitor_w*1)-window_w-40) (40)",
})
