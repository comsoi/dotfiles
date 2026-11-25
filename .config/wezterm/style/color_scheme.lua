local wezterm = require("wezterm")
local builtin_schemes = require("utils.builtin_schemes")
local M = {}

function M.scheme_for_appearance(appearance)
	if appearance:find("Light") then
		return "Catppuccin Frappe"
	end
	return "Catppuccin Macchiato"
end

-- 判断一个配色本身是不是浅底：appearance（桌面主题）和配色的明暗是两回事，
-- 这里的 Light 分支用的是 Frappe（暗底），所以不能按 appearance 决定对比度开关。
function M.is_light_scheme(name)
	local scheme = builtin_schemes.one(name)
	if not scheme then
		return false -- 自定义/外部 scheme 拿不到背景色，按暗底处理
	end
	local _, _, lightness = wezterm.color.parse(scheme.background):hsla()
	return lightness > 0.5
end

function M.apply(config)
	local scheme = M.scheme_for_appearance(wezterm.gui.get_appearance())
	config.color_scheme = scheme
	-- text_min_contrast_ratio 只改写「前景色」，而 render-markdown 用 █（前景色）
	-- 铺围栏行底色，暗底上 #1e2030 对比度只有 1.05，会被压成一条纯黑带。
	-- 因此只在真正浅底配色下才打开它。
	if M.is_light_scheme(scheme) then
		config.text_min_contrast_ratio = 1.25
	end
	-- 注：tab_bar.background 默认透明（appearance.lua）；右状态隐藏时的整行
	-- 填充由 style/tabline/collapse.lua 通过 per-window override 动态切换
end

return M
