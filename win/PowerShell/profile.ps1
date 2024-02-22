#Write-Host "PowerShell profile.ps1 is being executed" -ForegroundColor gray

# Import-Module
# >>> conda initialize >>>
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "D:\programs\conda\Scripts\conda.exe") {
    (& "D:\programs\conda\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion
# <<< conda initialize <<<

$env:SCOOP='D:\Scoop\'
$env:SCOOP_GLOBAL='D:\Scoop\'
Import-Module "$env:SCOOP\apps\gsudo\Current\gsudoModule.psd1"
# 自动建议
Import-Module PSReadLine
Invoke-Expression (&scoop-search --hook)
Invoke-Expression (&starship init powershell)
# oh-my-posh --init --shell pwsh --config ~/agnoster.minimal.omp.json | Invoke-Expression
Import-Module posh-git
# Dracula Prompt Configuration
$GitPromptSettings.DefaultPromptPrefix.Text = "$([char]0x2192) " # arrow unicode symbol
$GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Green
$GitPromptSettings.DefaultPromptPath.ForegroundColor =[ConsoleColor]::Cyan
$GitPromptSettings.DefaultPromptSuffix.Text = "$([char]0x203A) " # chevron unicode symbol
$GitPromptSettings.DefaultPromptSuffix.ForegroundColor = [ConsoleColor]::Magenta
# Dracula Git Status Configuration
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::Blue
# 彩色目录
Import-Module DirColors
Import-Module PSFzf


# Encoding
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$env:JAVA_TOOL_OPTIONS='-Dfile.encoding=UTF-8'
$env:PGCLIENTENCODING='utf-8'

# Color
# Dracula readline configuration. Requires version 2.0, if you have 1.2 convert to `Set-PSReadlineOption -TokenType`
Set-PSReadlineOption -Color @{
    "Command" = [ConsoleColor]::Green
    "Parameter" = [ConsoleColor]::Gray
    "Operator" = [ConsoleColor]::Magenta
    "Variable" = [ConsoleColor]::White
    "String" = [ConsoleColor]::Yellow
    "Number" = [ConsoleColor]::Blue
    "Type" = [ConsoleColor]::Cyan
    "Comment" = [ConsoleColor]::DarkCyan
}

### dotnet shortcuts ###
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# Set-PSReadLineOption -EditMode Windows
# 每次回溯输入历史，光标定位于输入内容末尾
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# 设置 Ctrl+d 为退出 PowerShell
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit
# 设置 Ctrl+z 为撤销
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo
# 设置C-u
Set-PSReadLineKeyHandler -Key "Ctrl+u" -Function BackwardDeleteLine
Set-PSReadLineKeyHandler -Key 'Ctrl+f' -Function AcceptSuggestion


## 设置向上键为后向搜索历史记录
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
## 设置向下键为前向搜索历史纪录
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward


# 设置预测文本来源为历史记录，（推荐）
# Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionSource HistoryAndPlugin # -PredictionViewStyle ListView # Optional
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
# 设置 Tab 为菜单补全显示所有选项的可导航菜单和 Intellisense，（推荐）
# Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# 点击 Tab 时补全
# Set-PSReadLineKeyHandler -Key Tab -Function Complete

#禁用 PowerShell 提示音
Set-PSReadlineOption -BellStyle None


#### common aliases ####
#禁用 PowerShell where
del alias:where -Force
remove-item alias:R
#实现 Bash 别名
New-Alias -Name np -Value notepad
New-Alias -Name vi -Value vim
New-Alias -Name which -Value Get-Command
New-Alias -Name python3 -Value python
### functions definitions ###
function code. {
    code $pwd
}
function e. {
    e $pwd
}
function e($path) {
    explorer $path
}
function StartPg {
#    Start-Process "cmd.exe" -ArgumentList "/c start /min pg_ctl start" -NoNewWindow
#    Start-Sleep -Seconds 1
#    nircmd win hide ititle "pg_ctl"
    pg_ctl start &
    # Start-Process "pg_ctl.exe" -ArgumentList "start" -WindowStyle Hidden
}

function touch {
    param ($filename)
    New-Item -Path $filename -ItemType file -Force
}

New-Alias -Name pgs -Value StartPg

#sudo(笑)

#function SwitchUser-Do {
#    if($args.Length -lt 1) {
#        Write-Warning("program must be provided!")
#        Write-Output("Usage: sudo program [args...]")
#        return
#    }
#    $program = $args[0]
#    $prog_args = $args[1..($args.Count-1)]
#    Write-Output("Program: " + $program)
#    if ($args.Length -le 1) {
#        Start-Process -FilePath $program -Verb RunAs
#    }
#    else {
#        Write-Output("Arguments: " + $prog_args)
#        Start-Process -FilePath $program -Verb RunAs -ArgumentList $prog_args
#    }
#}
#Set-Alias sudo SwitchUser-Do
# # NOTE: registry keys for IE 8, may vary for other versions
# $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
# function Clear-Proxy
# {
#     Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 0
#     Set-ItemProperty -Path $regPath -Name ProxyServer -Value ''
#     Set-ItemProperty -Path $regPath -Name ProxyOverride -Value ''

#     [Environment]::SetEnvironmentVariable('HTTP_PROXY', $null, 'User')
#     [Environment]::SetEnvironmentVariable('HTTPS_PROXY', $null, 'User')
# #    [System.Net.Http.HttpClient]::DefaultProxy = New-Object System.Net.WebProxy($null)
# #    sudo netsh winhttp reset proxy
# }

# function Set-Proxy
# {
#     $proxys = "http://127.0.0.1:7890"

#     Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 1
#     Set-ItemProperty -Path $regPath -Name ProxyServer -Value $proxy
#     Set-ItemProperty -Path $regPath -Name ProxyOverride -Value '<local>'

#     [Environment]::SetEnvironmentVariable('HTTP_PROXY', $proxys, 'User')
#     [Environment]::SetEnvironmentVariable('HTTPS_PROXY', $proxys, 'User')
# #    [System.Net.Http.HttpClient]::DefaultProxy = New-Object System.Net.WebProxy('http://127.0.0.1:7890')
# #    sudo netsh winhttp set proxy $proxys

# # Force PowerShell to use TLS 1.2 for connections
# 	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# 	[system.net.webrequest]::DefaultWebProxy = new-object system.net.webproxy($proxys)
# 	# If you need to import proxy settings from Internet Explorer, you can replace the previous line with the: "netsh winhttp import proxy source=ie"
# 	[system.net.webrequest]::DefaultWebProxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
# 	# You can request user credentials:
# 	# System.Net.WebRequest]::DefaultWebProxy.Credentials = Get-Credential
# 	# Also, you can get the user password from a saved XML file (see the article “Using saved credentials in PowerShell scripts”):
# 	# System.Net.WebRequest]::DefaultWebProxy= Import-Clixml -Path C:\PS\user_creds.xml
# 	[system.net.webrequest]::DefaultWebProxy.BypassProxyOnLocal = $true
# }





# $Env:Path = "$env:UCRT64/bin/;" + $Env:Path

function pset {
$env:HTTP_PROXY="http://127.0.0.1:2080"
$env:HTTPS_PROXY="http://127.0.0.1:2080"
}
