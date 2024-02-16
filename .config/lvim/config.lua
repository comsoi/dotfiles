-- user configs
lvim.keys.insert_mode["jj"] = "<ESC>"

local function in_zellij()
    return os.getenv("ZELLIJ") ~= nil
end

local function in_tmux()
    return os.getenv("TMUX") ~= nil
end

if in_zellij() then
    lvim.builtin.lualine.style = "default"
end

if in_tmux() then
    lvim.builtin.lualine.style = "default"
end
