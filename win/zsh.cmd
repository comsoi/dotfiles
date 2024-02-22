@echo off
setlocal EnableDelayedExpansion


set HOME=/c/Users/Lenod
set LANG=zh_CN.UTF-8
set CHERE_INVOKING=1
set aliases=

set LOGINSHELL=zsh

rem 设置 MSYS2 不使用 start 命令启动
set MSYS2_NOSTART=yes

rem 指定不使用特定的控制台
set MSYSCON=

rem 初始化 SHELL_ARGS 变量
set "SHELL_ARGS="

rem 收集从脚本调用传递的额外参数
set "msys2_full_cmd=%*"
for /f "tokens=*" %%i in ("!msys2_full_cmd!") do set "SHELL_ARGS=%%i"

rem 启动 zsh shell 并传递额外的命令行参数
"D:\Scoop\apps\git\current\usr\bin\zsh.exe" --login !SHELL_ARGS!

rem 退出并返回错误代码
exit /b %ERRORLEVEL%
