# env.sh
systemctl --user unset-environment QT_QPA_PLATFORMTHEME
systemctl --user unset-environment QT_IM_MODULE
systemctl --user daemon-reload
unset QT_QPA_PLATFORMTHEME
unset QT_IM_MODULE

export QT_ENABLE_HIGHDPI_SCALING=1

if [ -f /etc/systemd/system/display-manager.service ]; then
	DM_NAME=$(basename "$(readlink -f /etc/systemd/system/display-manager.service)")
	case "$DM_NAME" in
	*gdm*)
		[ -f "/etc/profile" ] && . "/etc/profile"
		[ -f "$HOME/.profile" ] && . "$HOME/.profile"
		;;
	esac
fi
