-- Passthrough submap: pass SUPER key through to Virtual Machine

-- Enter passthrough submap
hypr.bind.leader_key("CTRL + ALT + V", hl.dsp.submap("passthru"))

hl.define_submap("passthru", function()

    -- Exit binds
    hypr.bind.leader_key("escape", hl.dsp.submap("reset"))
    hl.bind("ALT + escape", hl.dsp.submap("reset"))

end)
