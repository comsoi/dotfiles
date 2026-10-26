-- Ignore maximize requests from all apps
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Fix popup widget blur around borders (XWayland)
hl.window_rule({
    name  = "no-blur-xwayland-popups",
    match = {
        class    = "^$",
        title    = "^$",
        xwayland = true,
    },
    no_blur = true,
})

-- xwaylandvideobridge
hl.window_rule({
    name             = "hide-xwaylandvideobridge",
    match            = { class = "^(xwaylandvideobridge)$" },
    opacity          = "0.0 override",
    no_anim          = true,
    no_initial_focus = true,
    max_size         = { 1, 1 },
    no_blur          = true,
    no_focus         = true,
})

-- Browser Picture-in-Picture
hl.window_rule({
    name  = "pip-float-en",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
    move  = "((monitor_w*0.695)) ((monitor_h*0.04))",
})

hl.window_rule({
    name  = "pip-float-zh",
    match = { title = "^(画中画)$" },
    float = true,
    pin   = true,
    move  = "((monitor_w*0.695)) ((monitor_h*0.04))",
})

-- Gromit-mpx (annotation overlay)
hl.window_rule({
    name             = "gromit-mpx-overlay",
    match            = { class = "^(Gromit-mpx)$" },
    no_blur          = true,
    opacity          = "1.0 override",
    no_shadow        = true,
    fullscreen_state = "1 0",
})
