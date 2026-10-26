
require("colors")

utils  = require("lib.utils")
hypr   = require("lib.api")
config = require("config")

config.setup({
	nvidia   = { enable = true },
	monitors = { scenario = "home" },
})


-- For Noctalia Color templates
require("noctalia").apply_theme()
