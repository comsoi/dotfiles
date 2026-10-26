-- floating alacritty terminal
hl.workspace_rule({
    workspace         = "special:special",
    on_created_empty  = "[float; move 15% 15%; size 70% 70%] alacritty-sock.sh",
})

-- gromit annotation (no gaps)
hl.workspace_rule({
    workspace         = "special:gromit",
    gaps_in           = 0,
    gaps_out          = 0,
    on_created_empty  = "gromit-mpx",
})

