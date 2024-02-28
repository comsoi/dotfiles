#IfWinNotActive ahk_exe WindowsTerminal.exe
#IfWinNotActive ahk_exe wezterm-gui.exe
#IfWinNotActive ahk_exe alacritty.exe
!h::Send, {Left}
!l::Send, {Right}
!j::Send, {Down}
!k::Send, {Up}
#IfWinActive ahk_exe WindowsTerminal.ahk_exe
#IfWinActive ahk_exe wezterm-gui.exe
#IfWinActive ahk_exe alacritty.exe
#c::Send, {#c}
