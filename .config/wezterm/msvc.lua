local wezterm = require("wezterm")

local M = {}

M.launch_menu = {
	{
		label = "Zsh",
		args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" },
	},
	{
		label = "PowerShell",
		args = { "pwsh.exe", "-NoLogo" },
	},
	{
		label = "MSYS2",
		args = {
			"D:/Scoop/apps/msys2/current/msys2_shell.cmd",
			"-defterm",
			"-no-start",
			"-use-full-path",
			"-here",
			"-msys",
			"-shell",
			"fish",
		},
	},
	{
		label = "MSYS2/UCRT64",
		args = {
			"D:/Scoop/apps/msys2/current/msys2_shell.cmd",
			"-defterm",
			"-no-start",
			"-here",
			"-ucrt64",
			"-shell",
			"zsh",
		},
	},
	{
		label = "cmder",
		args = { "cmd.exe", "/k", "title Cmder/Cmd & ", "%CMDER_ROOT%\\vendor\\init.bat" },
	},
	{
		label = "nushell",
		args = { "D:/Scoop/apps/nu/current/nu.exe" },
	},
	{
		label = "Zsh",
		args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" },
	},
	{
		label = "PowerShell",
		args = { "pwsh.exe", "-NoLogo" },
	},
	{
		label = "MSYS2",
		args = {
			"D:/Scoop/apps/msys2/current/msys2_shell.cmd",
			"-defterm",
			"-no-start",
			"-use-full-path",
			"-here",
			"-msys",
			"-shell",
			"fish",
		},
	},
	{
		label = "MSYS2/UCRT64",
		args = {
			"D:/Scoop/apps/msys2/current/msys2_shell.cmd",
			"-defterm",
			"-no-start",
			"-here",
			"-ucrt64",
			"-shell",
			"zsh",
		},
	},
	{
		label = "cmder",
		args = { "cmd.exe", "/k", "title Cmder/Cmd & ", "%CMDER_ROOT%\\vendor\\init.bat" },
	},
	{
		label = "nushell",
		args = { "D:/Scoop/apps/nu/current/nu.exe" },
	},
}

M.win_keybindings = {
	-- { key = "Return", mods = "ALT", action = "ToggleFullScreen" },
	{
		key = "!", -- 1
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" },
			domain = { DomainName = "local" },
		}),
	},
	{
		key = "@", -- 2
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "pwsh.exe", "-NoLogo" },
			domain = { DomainName = "local" },
		}),
	},
	{
		key = "#", -- 3
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			domain = { DomainName = "WSL:Devuan" },
		}),
	},
	{
		key = "$", -- 4
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			domain = { DomainName = "WSL:ArchWSL" },
		}),
	},
	{
		key = "!", -- 1
		mods = "CTRL|SHIFT|LEADER",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" },
		}),
	},
	{
		key = "@", -- 2
		mods = "CTRL|SHIFT|LEADER",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "pwsh.exe", "-NoLogo" },
		}),
	},
	{
		key = "#", -- 3
		mods = "CTRL|SHIFT|LEADER",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "wsl.exe", "--distribution", "Devuan" },
		}),
	},
	{
		key = "$", -- 4
		mods = "CTRL|SHIFT|LEADER",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "wsl.exe", "--distribution", "ArchWSL" },
		}),
	},
}

-- 定义初始化函数
function M.apply(config)
	config.default_prog = { "wsl.exe", "-d", "Devuan" }

	local wsl_domains = wezterm.default_wsl_domains()
	for idx = #wsl_domains, 1, -1 do
		if wsl_domains[idx].name == "WSL:docker-desktop-data" or wsl_domains[idx].name == "WSL:docker-desktop" then
			table.remove(wsl_domains, idx)
		end
	end
	config.wsl_domains = wsl_domains

	config.skip_close_confirmation_for_processes_named = {
		"bash.exe",
		"sh.exe",
		"zsh.exe",
		"fish.exe",
		"tmux.exe",
		"nu.exe",
		"cmd.exe",
		"pwsh.exe",
		"powershell.exe",
		"wslhost.exe",
		"wsl.exe",
		"conhost.exe",
	}

	for _, vsvers in ipairs(wezterm.glob("Microsoft Visual Studio/20*", "C:/Program Files")) do
		local year = vsvers:gsub("Microsoft Visual Studio/", "")
		table.insert(M.launch_menu, {
			label = "Developer Command Prompt for VS " .. year,
			args = {
				"cmd.exe",
				"/k",
				"C:/Program Files/" .. vsvers .. "/Community/Common7/Tools/VsDevCmd.bat",
				"-arch=x64",
				"-host_arch=x64",
				"&",
				"%CMDER_ROOT%\\vendor\\init.bat",
			},
		})
		table.insert(M.launch_menu, {
			label = "Developer Pwsh for VS " .. year,
			args = {
				"pwsh.exe",
				"-noe",
				"-c",
				'&{Import-Module "C:/Program Files/'
					.. vsvers
					.. '/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell f14d0f99}',
			},
		})
	end
	config.launch_menu = M.launch_menu

	for _, key in ipairs(M.win_keybindings) do
		table.insert(config.keys, key)
	end

	config.color_scheme = "Catppuccin Macchiato"
	config.set_environment_variables = {}
	config.win32_system_backdrop = "Acrylic"

	return config
end

return M
