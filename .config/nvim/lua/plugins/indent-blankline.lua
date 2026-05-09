return {
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("ibl").setup({
				exclude = {
					filetypes = {
						"Trouble",
						"alpha",
						"dashboard",
						"help",
						"lazy",
						"mason",
						"neo-tree",
						"notify",
						"snacks_dashboard",
						"snacks_notif",
						"snacks_terminal",
						"snacks_win",
						"toggleterm",
						"trouble",
					},
				},
			})
		end,
		main = "ibl",
		opts = function()
			Snacks.toggle({
				name = "Indention Guides",
				get = function()
					return require("ibl.config").get_config(0).enabled
				end,
				set = function(state)
					require("ibl").setup_buffer(0, { enabled = state })
				end,
			}):map("<leader>ug")
		end,
	},

	{
		"snacks.nvim",
		opts = {
			dashboard = { enabled = false },
			-- indent = { enabled = false },
		},
	},
}
