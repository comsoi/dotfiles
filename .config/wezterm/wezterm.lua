-- 入口：只做接线，逻辑在各目录的 M.apply(config) 里。
-- 顺序：style → keybindings → platforms → utils（utils/init.lua 内部按 save_output →
-- smart-splits → find_pane 装配）。
--
-- 改这个文件时的硬规则（踩过的）：
--
-- `return config` 必须是最后一条语句。Lua 要求 return 是块内最后一句，在它后面追加任何
-- 代码都是语法错误；而**配置加载失败时 wezterm 会静默回退到默认键位，stderr 一个字都不给**。
-- 所以临时调试代码一律加在 return 之前，改完用
--     wezterm --config-file ~/.config/wezterm/wezterm.lua show-keys --lua | wc -l
-- 核对行数（当前 291），不要靠"看着没报错"。
local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("style.init").apply(config)
require("keybindings.init").apply(config)
require("platforms.init").apply(config)
require("utils.init").apply(config)

return config
