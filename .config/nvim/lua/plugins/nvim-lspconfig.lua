return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				['*'] = {
					keys = {
						-- Disable <C-k> keymap as in your previous config
						{ "<C-k>", false },
					},
				},
			},
		},
	},
}
