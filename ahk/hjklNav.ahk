#IfWinNotActive ahk_exe WindowsTerminal.exe
!h::Send, {Left}
!l::Send, {Right}
!j::Send, {Down}
!k::Send, {Up}
#IfWinActive
