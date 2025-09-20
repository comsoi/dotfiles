# 70-env.sh

# export QT_ENABLE_HIGHDPI_SCALING=1

if [ -f /etc/systemd/system/display-manager.service ]; then
	DM_NAME=$(basename "$(readlink -f /etc/systemd/system/display-manager.service)")
	case "$DM_NAME" in
	*sddm*) ;;
	*)
		[ -f "/etc/profile" ] && . "/etc/profile"
		[ -f "$HOME/.profile" ] && . "$HOME/.profile"
		;;
	esac
fi
