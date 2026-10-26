-- Smart gaps: no gaps on single-window tiled workspaces
hl.workspace_rule({ workspace = "w[tv1]",             gaps_out = 7,  gaps_in = 0 })
hl.workspace_rule({ workspace = "w[tv1] m[HDMI-A-1]", gaps_out = 14, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",               gaps_out = 7,  gaps_in = 0 })

