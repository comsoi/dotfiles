# KDE Plasma
systemctl --user add-wants plasma-workspace-wayland.target plasma-workspace-wayland-env.service
# Hyprland
systemctl --user add-wants wayland-wm@hyprland.desktop.service hyprpolkitagent.service
systemctl --user add-wants wayland-wm@hyprland.desktop.service hypridle.service
systemctl --user add-wants wayland-wm@hyprland.desktop.service hyprpaper.service
systemctl --user add-wants wayland-wm@hyprland.desktop.service hyprsunset.service
# WM
systemctl --user add-wants wayland-wm@.service swaync.service
systemctl --user add-wants wayland-wm@.service waybar.service
systemctl --user add-wants wayland-wm@.service plasma-xembedsniproxy.service
systemctl --user add-wants wayland-wm@.service sunsetr.service
elephant service enable
systemctl --user add-wants wayland-wm@.service elephant.service
