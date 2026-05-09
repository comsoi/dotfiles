return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			-- Set debug logging
			-- log_level = "DEBUG",
		},
	},
	{
		"zbirenbaum/copilot.lua",
		opts = function()
			require("copilot.api").status = require("copilot.status")
		end,
	},
}
