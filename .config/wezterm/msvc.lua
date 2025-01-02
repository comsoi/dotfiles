local wezterm = require("wezterm")
local keymap = require("keymap")

-- 定义模块表
local msvc = {}

-- 定义初始化函数
function msvc.apply(config)
	local wsl_domains = wezterm.default_wsl_domains()
	config.default_prog = { "wsl.exe", "-d", "Devuan" }
	config.keys = keymap.keys
	config.mouse_bindings = keymap.mouse_bindings
	config.leader = keymap.leader
	config.key_tables = keymap.key_tables

	-- 过滤 WSL 域
	for idx = #wsl_domains, 1, -1 do
		if wsl_domains[idx].name == 'WSL:docker-desktop-data'
			or wsl_domains[idx].name == 'WSL:docker-desktop' then
			table.remove(wsl_domains, idx)
		end
	end
	config.wsl_domains = wsl_domains

	-- 设置跳过关闭确认的进程
	config.skip_close_confirmation_for_processes_named = {
		'bash.exe',
		'sh.exe',
		'zsh.exe',
		'fish.exe',
		'tmux.exe',
		'nu.exe',
		'cmd.exe',
		'pwsh.exe',
		'powershell.exe',
		"wslhost.exe",
		"wsl.exe",
		"conhost.exe",
	}

	-- 设置启动菜单
	config.launch_menu = {
		{
			label = "Zsh",
			args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" }
		},
		{
			label = "PowerShell",
			args = { "pwsh.exe", "-NoLogo" }
		},
		{
			label = "MSYS2",
			args = { "D:/Scoop/apps/msys2/current/msys2_shell.cmd", "-defterm", "-no-start", "-use-full-path", "-here", "-msys", "-shell", "fish" }
		},
		{
			label = "MSYS2/UCRT64",
			args = { "D:/Scoop/apps/msys2/current/msys2_shell.cmd", "-defterm", "-no-start", "-here", "-ucrt64", "-shell", "zsh" }
		},
		{
			label = "cmder",
			args = { "cmd.exe", "/k", "title Cmder/Cmd & ", "%CMDER_ROOT%\\vendor\\init.bat" }
		},
		{
			label = "nushell",
			args = { "D:/Scoop/apps/nu/current/nu.exe" }
		}
	}
	for _, vsvers in ipairs(wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files')) do
		local year = vsvers:gsub('Microsoft Visual Studio/', '')
		table.insert(config.launch_menu, {
			label = 'Developer Command Prompt for VS ' .. year,
			args = {
				'cmd.exe', '/k',
				'C:/Program Files/' .. vsvers .. '/Community/Common7/Tools/VsDevCmd.bat',
				'-arch=x64', '-host_arch=x64', '&',
				'%CMDER_ROOT%\\vendor\\init.bat'
			}
		})
		table.insert(config.launch_menu, {
			label = 'Developer Pwsh for VS ' .. year,
			args = {
				'pwsh.exe', '-noe', '-c',
				'&{Import-Module "C:/Program Files/' ..
				vsvers .. '/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell f14d0f99}'
			}
		})
	end
	-- 按键绑定
	local winkeys = {
		-- { key = "Return", mods = "ALT", action = "ToggleFullScreen" },
		{
			key = '!', -- 1
			mods = 'CTRL|SHIFT',
			action = wezterm.action.SpawnCommandInNewTab {
				args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" },
				domain = { DomainName = 'local' },
			},
		},
		{
			key = '@', -- 2
			mods = 'CTRL|SHIFT',
			action = wezterm.action.SpawnCommandInNewTab {
				args = { "pwsh.exe", "-NoLogo" },
				domain = { DomainName = 'local' },
			},
		},
		{
			key = '#', -- 3
			mods = 'CTRL|SHIFT',
			action = wezterm.action.SpawnCommandInNewTab {
				domain = { DomainName = 'WSL:Devuan' },
			},
		},
		{
			key = '$', -- 4
			mods = 'CTRL|SHIFT',
			action = wezterm.action.SpawnCommandInNewTab {
				domain = { DomainName = 'WSL:ArchWSL' },
			},
		},
		{
			key = '!', -- 1
			mods = 'CTRL|SHIFT|LEADER',
			action = wezterm.action.SpawnCommandInNewTab {
				args = { "D:/Scoop/apps/git/current/usr/bin/zsh.exe", "-l" }
			},
		},
		{
			key = '@', -- 2
			mods = 'CTRL|SHIFT|LEADER',
			action = wezterm.action.SpawnCommandInNewTab {
				args = { "pwsh.exe", "-NoLogo" },
			},
		},
		{
			key = '#', -- 3
			mods = 'CTRL|SHIFT|LEADER',
			action = wezterm.action.SpawnCommandInNewTab {
				args = { "wsl.exe", "--distribution", "Devuan" },
			},
		},
		{
			key = '$', -- 4
			mods = 'CTRL|SHIFT|LEADER',
			action = wezterm.action.SpawnCommandInNewTab {
				args = { "wsl.exe", "--distribution", "ArchWSL" },
			},
		},
	}
	for _, key in ipairs(winkeys) do
		table.insert(config.keys, key)
	end

	config.color_scheme = "Catppuccin Macchiato"
	config.set_environment_variables = {}
	config.win32_system_backdrop = 'Acrylic'

	-- 返回最终的配置
	return config
end

-- 返回模块表
return msvc
