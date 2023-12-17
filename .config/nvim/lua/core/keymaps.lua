-- 设置 leader 键
vim.g.mapleader = " "
local keymap = vim.keymap
-- vim.api.nvim_set_keymap = vim.keymap.set


-- ---------- 正常模式 ---------- ---
keymap.set('n', '<Leader>y', '"+y', { noremap = true, silent = true })
keymap.set('n', '<Leader>p', '"+p', { noremap = true, silent = true })
keymap.set('n', '<Leader>P', '"+P', { noremap = true, silent = true })

-- ---------- 插入模式 ---------- ---
keymap.set('i', 'jj', '<esc>', { silent = true })

-- ---------- 可视模式 ---------- ---
keymap.set('v', '<Leader>y', '"+y')
keymap.set('v', '<Leader>p', '"+p')
keymap.set('v', '<Leader>P', '"+P')

-- ---------- 可视行模式 ---------- ---
keymap.set('x', '<Leader>y', '"+y')
keymap.set('x', '<Leader>p', '"+p')
keymap.set('x', '<Leader>P', '"+P')
