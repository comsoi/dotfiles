-- Tmux-like control submap for resizing and moving windows
-- Activated by SUPER + S

hypr.bind.leader_key("S", hl.dsp.submap("ctl"))

hl.define_submap("ctl", function()

    -- Focus movement
    hl.bind("h", hl.dsp.focus({ direction = "left" }),  { repeating = true })
    hl.bind("l", hl.dsp.focus({ direction = "right" }), { repeating = true })
    hl.bind("k", hl.dsp.focus({ direction = "up" }),    { repeating = true })
    hl.bind("j", hl.dsp.focus({ direction = "down" }),  { repeating = true })

    -- Window resize
    hl.bind("SHIFT + h", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + l", hl.dsp.window.resize({ x = 100, y = 0, relative = true }),  { repeating = true })
    hl.bind("SHIFT + k", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true })
    hl.bind("SHIFT + j", hl.dsp.window.resize({ x = 0, y = 100, relative = true }),  { repeating = true })

    -- Workspace navigation
    hl.bind("n", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
    hl.bind("p", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })

    -- Switch workspace 1-10
    for i = 1, 10 do
        local key = i % 10
        hl.bind(tostring(key),       hl.dsp.focus({ workspace = i }),       { repeating = true })
        hl.bind("SHIFT + " .. key,      hl.dsp.window.move({ workspace = i }), { repeating = true })
        hl.bind("CTRL + " .. key, function()
            hypr.window.move_all_to(i)
            hl.dispatch(hl.dsp.focus({ workspace = i }))
        end, { repeating = true })
    end

    -- Group navigation
    hl.bind("SUPER + Tab",       hl.dsp.group.next(), { repeating = true })
    hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev(), { repeating = true })
    hl.bind("Tab",            hl.dsp.focus({ workspace = "m+1" }), { repeating = true })
    hl.bind("SHIFT + Tab",       hl.dsp.focus({ workspace = "m-1" }), { repeating = true })

    -- Mouse scroll workspaces
    hl.bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
    hl.bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { repeating = true })

    -- Terminal
    hl.bind("c", hypr.dsp.exec("uwsm-app alacritty-sock.sh || alacritty-sock.sh"), { repeating = true })

    -- Exit submap
    hl.bind("escape",     hl.dsp.submap("reset"))
    hl.bind("q",          hl.dsp.submap("reset"))
    hl.bind("CTRL + C",      hl.dsp.submap("reset"))
    -- hl.bind("SUPER + S",      hl.dsp.submap("reset"))
    hl.bind("SUPER + escape", hl.dsp.submap("reset"))

end)
