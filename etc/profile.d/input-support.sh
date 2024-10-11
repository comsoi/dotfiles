# https://wiki.archlinux.org/index.php/Fcitx
# https://wiki.archlinux.org/index.php/Fcitx5
im=fcitx
export XMODIFIERS=@im=$im
export INPUT_METHOD=$im
export SDL_IM_MODULE=$im

# Only set GTK_IM_MODULE and QT_IM_MODULE if not using Wayland
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    export GTK_IM_MODULE=$im
    export QT_IM_MODULE=$im
fi

