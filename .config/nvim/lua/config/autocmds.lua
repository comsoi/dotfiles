-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		vim.fn.system("fcitx5-remote -c")
	end,
	desc = "Switch off fcitx input method on InsertLeave",
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("TransparentEnable")
		if vim.g.neovide or vim.env.TERM_PROGRAM == "WezTerm" then
			vim.cmd("TransparentDisable")
		end
	end,
})
