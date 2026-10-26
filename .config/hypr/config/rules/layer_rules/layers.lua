-- Waybar
hl.layer_rule({
    name         = "waybar-blur",
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0.1,
})

-- SwayNC control center
hl.layer_rule({
    name         = "swaync-cc-blur",
    match        = { namespace = "swaync-control-center" },
    blur         = true,
    ignore_alpha = 0,
})

-- SwayNC notification popups
hl.layer_rule({
    name         = "swaync-notif-blur",
    match        = { namespace = "swaync-notification-window" },
    blur         = true,
    ignore_alpha = 0.6,
})
