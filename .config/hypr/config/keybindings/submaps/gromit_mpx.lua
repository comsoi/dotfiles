-- Gromit-mpx annotation submap
-- Provides on-screen drawing annotation while in submap mode

-- Enter submap + toggle annotation overlay
hypr.bind.leader_key("CTRL + D", hl.dsp.workspace.toggle_special("gromit"))
hypr.bind.leader_key("CTRL + D", hypr.dsp.exec("gromit-mpx --toggle"))
hypr.bind.leader_key("CTRL + D", hl.dsp.submap("gromit"))

hl.define_submap("gromit", function()

    -- Drawing controls
    hl.bind("SHIFT + F9", hypr.dsp.exec("gromit-mpx --clear"))
    hl.bind("F9",      hypr.dsp.exec("gromit-mpx --toggle"))
    hl.bind("SHIFT + F8", hypr.dsp.exec("gromit-mpx --redo"))
    hl.bind("F8",      hypr.dsp.exec("gromit-mpx --undo"))

    -- Quit annotation (ALT + F9)
    hl.bind("ALT + F9", hypr.dsp.exec("gromit-mpx --quit"))
    hl.bind("ALT + F9", hl.dsp.workspace.toggle_special("gromit"))
    hl.bind("ALT + F9", hl.dsp.submap("reset"))

    -- Toggle annotation (CTRL + F9)
    hl.bind("CTRL + F9", hypr.dsp.exec("gromit-mpx --toggle"))
    hl.bind("CTRL + F9", hl.dsp.workspace.toggle_special("gromit"))
    hl.bind("CTRL + F9", hl.dsp.submap("reset"))

    -- Toggle off (SUPER CTRL + D again)
    hypr.bind.leader_key("CTRL + D", hypr.dsp.exec("gromit-mpx --toggle"))
    hypr.bind.leader_key("CTRL + D", hl.dsp.workspace.toggle_special("gromit"))
    hypr.bind.leader_key("CTRL + D", hl.dsp.submap("reset"))

    -- Exit submap
    hl.bind("SUPER + ESCAPE", hypr.dsp.exec("gromit-mpx --toggle"))
    hl.bind("SUPER + ESCAPE", hl.dsp.workspace.toggle_special("gromit"))
    hl.bind("SUPER + ESCAPE", hl.dsp.submap("reset"))

end)
