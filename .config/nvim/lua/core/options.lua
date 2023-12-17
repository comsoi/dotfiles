local opt = vim.opt

-- 剪贴板设置
-- opt.clipboard:append("unnamedplus")
-- 设置与 vi 不兼容
opt.compatible = false

-- 空格而非制表符，制表符宽度设定
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.textwidth = 80

-- 行号设置
opt.number = true
opt.relativenumber = true

-- 光标所在行高亮
opt.cursorline = true

-- 可视铃声
opt.visualbell = true

-- 长行处理
opt.linebreak = false

-- 防止包裹
opt.wrap = false

-- 模式行设置
opt.modeline = true
opt.modelines = 2

-- 滚动偏移
opt.scrolloff = 3


-- 启用鼠标
opt.mouse:append("a")

-- 智能缩进
opt.smartindent = true
opt.autoindent = true

-- 搜索相关设置
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- 语法高亮和文件类型检测
vim.cmd('syntax on')
vim.cmd('filetype plugin on')
vim.cmd('filetype indent on')
