dms ipc call theme "$WM_DMS"
qs -c noctalia-shell ipc call darkMode "$WM_QS"

case "$XDG_CURRENT_DESKTOP" in
    *GNOME*|*KDE*|*XFCE*|*X-Cinnamon*|*MATE*|*LXQt*|*Deepin*|*Enlightenment*) ;;
    *)
        wallpaper_backends=(
            "awww-daemon" "swww-daemon" "hyprpaper"
            "swaybg" "wallutils" "gslapper" "mpvpaper"
        )
        for backend in "${wallpaper_backends[@]}"; do
            pgrep -x "$backend" > /dev/null 2>&1 || continue
            waypaper --restore
            break
        done
        ;;
esac
