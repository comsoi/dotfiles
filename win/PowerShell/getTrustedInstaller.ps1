$ConfirmPreference = "None"
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process pwsh -ArgumentList "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
# Set-ExecutionPolicy -ExecutionPolicy bypass
# Install-Module -Name NtObjectManager
Start-Service -Name TrustedInstaller
$parent = Get-NtProcess -ServiceName TrustedInstaller
# $proc = New-Win32Process cmd.exe -CreationFlags NewConsole -ParentProcess $parent
$proc = New-Win32Process "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.19.10821.0_x64__8wekyb3d8bbwe\wt.exe"
$ConfirmPreference = "High"