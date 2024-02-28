; 检测当前活跃窗口的进程名，如果不是终端程序之一，允许快捷键发送方向键
#If (!IsTerminalActive())
    !h::Send, {Left}
    !l::Send, {Right}
    !j::Send, {Down}
    !k::Send, {Up}
#If

; 检查当前活跃的窗口是否是终端窗口
IsTerminalActive() {
    WinGet, activeProcess, ProcessName, A
    return (activeProcess = "WindowsTerminal.exe"
        or activeProcess = "wezterm-gui.exe"
        or activeProcess = "alacritty.exe")
}
