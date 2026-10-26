#!/bin/bash
# Power-aware idle action dispatcher
# Usage: action.sh <action> --battery|--ac

AC_ONLINE="/sys/class/power_supply/ADP1/online"
BAT_DIM_MIN=75
AC_DIM_MIN=100
DIM_PERCENT="40%-"

ac_online=$(cat "$AC_ONLINE" 2>/dev/null || echo 0)
action="$1"
mode="$2"

case "$mode" in
--battery) [ "$ac_online" = "1" ] && exit 0 ;;
--ac)      [ "$ac_online" = "0" ] && exit 0 ;;
*)
	echo "Usage: $0 <action> --battery|--ac"
	echo "Actions: dim, lock, dpms-locked, dpms-off, suspend"
	exit 1
	;;
esac

case "$action" in
dim)
	[ "$mode" = "--ac" ] && min="$AC_DIM_MIN" || min="$BAT_DIM_MIN"
	brightnessctl -s set --min-value="$min" "$DIM_PERCENT"
	;;
lock)        loginctl lock-session ;;
dpms-locked) pidof hyprlock && hyprctl dispatch 'hl.dsp.dpms({action = "off"})' ;;
dpms-off)    hyprctl dispatch 'hl.dsp.dpms({action = "off"})' ;;
suspend)     systemctl suspend ;;
*)
	echo "Usage: $0 <action> --battery|--ac"
	echo "Actions: dim, lock, dpms-locked, dpms-off, suspend"
	exit 1
	;;
esac
