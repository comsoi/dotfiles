-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local k = vim.keymap

k.set("i", "jj", "<esc>", { silent = true })
k.set("i", "<C-BS>", "<C-W>", { silent = true })

k.del({ "i", "n" }, "<A-j>")
k.del({ "i", "n" }, "<A-k>")
-- k.del("i", "C-k")

vim.keymap.set('n', '<leader>y', '<Plug>OSCYankOperator')
vim.keymap.set('n', '<leader>yy', '<leader>y_', {remap = true})
vim.keymap.set('v', '<leader>y', '<Plug>OSCYankVisual')

k.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)
k.set("n", "<A-h>", require("smart-splits").move_cursor_left)
k.set("n", "<A-j>", require("smart-splits").move_cursor_down)
k.set("n", "<A-k>", require("smart-splits").move_cursor_up)
k.set("n", "<A-l>", require("smart-splits").move_cursor_right)

k.set("n", "<A-left>", require("smart-splits").resize_left)
k.set("n", "<A-down>", require("smart-splits").resize_down)
k.set("n", "<A-right>", require("smart-splits").resize_right)
k.set("n", "<A-up>", require("smart-splits").resize_up)

-- Move Lines
k.set("n", "<C-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
k.set("n", "<C-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
k.set("i", "<C-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
k.set("i", "<C-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
k.set("v", "<C-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
k.set("v", "<C-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

k.set("n", "<F5>", "<cmd>set list!<cr>", { desc = "Toggle list" })

-- CodeCompanion.nvim
k.set({ "n", "v" }, "<C-A-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
k.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
k.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- if vim.g.neovide then
-- 	vim.keymap.set("v", "<C-S-c>", '"+y') -- Copy
-- 	vim.keymap.set("n", "<C-S-v>", '"+P') -- Paste normal mode
-- 	vim.keymap.set("v", "<C-S-v>", '"+P') -- Paste visual mode
-- 	vim.keymap.set("c", "<C-S-v>", "<C-R>+") -- Paste command mode
-- 	vim.keymap.set("i", "<C-S-v>", '<ESC>l"+Pli') -- Paste insert mode
-- end

-- vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
