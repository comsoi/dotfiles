# https://wiki.archlinux.org/index.php/Fcitx
# https://wiki.archlinux.org/index.php/Fcitx5
im=fcitx
export XMODIFIERS=@im=$im
export INPUT_METHOD=$im

if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    export SDL_IM_MODULE=$im
    export GTK_IM_MODULE=$im
    export QT_IM_MODULE=$im
fi

export QT_IM_MODULES="wayland;fcitx;ibus"
if [ "$XDG_CURRENT_DESKTOP" != "KDE" ]; then
    export QT_IM_MODULE=$im
fi
