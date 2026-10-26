# 主题同步：dms 和 noctalia(noc) 谁在跑就同步谁；两个都没跑也不报错、不中断
# 不要改成"检测到哪个再调用"之外的短路写法，两者可以随时切换使用
if command -v dms >/dev/null 2>&1; then
	if timeout 5 dms ipc call theme "$WM_DMS" >/dev/null 2>&1; then
		echo "dms 已同步主题：$WM_DMS"
	else
		echo "dms 未运行或调用失败，跳过主题同步"
	fi
else
	echo "dms 未安装，跳过主题同步"
fi

# noctalia v5 起自带 CLI，旧的 quickshell(qs) 入口已废弃；两者都不在就跳过
if command -v noctalia >/dev/null 2>&1; then
	if noctalia msg theme-mode-set "$WM_DMS" >/dev/null 2>&1; then
		echo "noctalia 已同步主题模式：$WM_DMS"
	else
		echo "noctalia 未运行或调用失败，跳过主题同步"
	fi
elif command -v qs >/dev/null 2>&1; then
	if qs -c noctalia-shell ipc call darkMode "$WM_QS" >/dev/null 2>&1; then
		echo "quickshell 的 noctalia-shell 已同步主题：$WM_QS"
	else
		echo "quickshell 的 noctalia-shell 未运行，跳过主题同步"
	fi
fi

case "$XDG_CURRENT_DESKTOP" in
    *GNOME*|*KDE*|*XFCE*|*X-Cinnamon*|*MATE*|*LXQt*|*Deepin*|*Enlightenment*)
        echo "当前桌面环境（$XDG_CURRENT_DESKTOP）自管壁纸，跳过壁纸重载"
        ;;
    *)
        wallpaper_backends=(
            "awww-daemon" "swww-daemon" "hyprpaper"
            "swaybg" "wallutils" "gslapper" "mpvpaper"
        )
        wallpaper_done=""
        for backend in "${wallpaper_backends[@]}"; do
            pgrep -x "$backend" > /dev/null 2>&1 || continue
            if ! command -v waypaper >/dev/null 2>&1; then
                echo "waypaper 未安装，跳过壁纸重载"
                wallpaper_done=1
                break
            fi
            if waypaper --restore > /dev/null 2>&1; then
                echo "壁纸后端 '$backend' 在运行，已执行 waypaper --restore"
            else
                echo "壁纸后端 '$backend' 在运行，但 waypaper --restore 失败"
            fi
            wallpaper_done=1
            break
        done
        if [[ -z "$wallpaper_done" ]]; then
            echo "没有壁纸后端在运行，跳过壁纸重载"
        fi
        ;;
esac
