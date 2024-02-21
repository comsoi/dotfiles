#IfWinNotActive ahk_exe WindowsTerminal.exe
!h::Send, {Left}
!l::Send, {Right}
!j::Send, {Down}
!k::Send, {Up}
#IfWinActive  ahk_exe wezterm-gui.exe
#c::Send, {#c}
