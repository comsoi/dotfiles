# KDE Plasma
systemctl --user add-wants plasma-workspace-wayland.target plasma-workspace-wayland-env.service
# Hyprland
systemctl --user add-wants wayland-wm@hyprland.desktop.service hyprpolkitagent.service hypridle.service hyprpaper.service hyprsunset.service
# WM
systemctl --user add-wants wayland-wm@.target waybar.service plasma-xembedsniproxy.service swaync.service sunsetr.service
