-- user configs
lvim.keys.insert_mode["jj"] = "<ESC>"
-- 检查是否在 Zellij 中
local function in_zellij()
    return os.getenv("ZELLIJ") ~= nil
end

-- 根据是否在 Zellij 中设置 lualine 样式
if in_zellij() then
    lvim.builtin.lualine.style = "default"
end
