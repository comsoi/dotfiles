#!/bin/bash

if systemctl --user is-active --quiet waypaper-random.timer; then
	systemctl --user stop waypaper-random.timer
	notify-send "随机壁纸已停止" \
		"壁纸将不再自动更换。" \
		--app-name="系统定时器" \
		--icon=process-stop \
		--urgency=low
else
	systemctl --user start waypaper-random.timer
	notify-send "随机壁纸已启动" \
		"壁纸将每5分钟更换一次。" \
		--app-name="系统定时器" \
		--icon=media-playback-start \
		--urgency=low
fi
