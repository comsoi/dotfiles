#!/bin/sh

export KWIN_USE_OVERLAYS=1
export KWIN_IM_SHOW_ALWAYS=1

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
