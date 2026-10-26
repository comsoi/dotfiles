-------------------------------
-- Standalone keys (Fn keys) --
-------------------------------

-- Brightness
hl.bind("XF86MonBrightnessUp",
    hypr.dsp.exec("swayosd-client --brightness +5 --device intel_backlight || brightnessctl -q s +5%"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",
    hypr.dsp.exec("swayosd-client --brightness -5 --device intel_backlight || brightnessctl -q s 5%-"),
    { locked = true, repeating = true })

-- Volume
hl.bind("XF86AudioRaiseVolume",
    hypr.dsp.exec("swayosd-client --output-volume 5 --max-volume 100 || wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",
    hypr.dsp.exec("swayosd-client --output-volume -5 || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioRaiseVolume",
    hypr.dsp.exec("swayosd-client --output-volume 1 --max-volume 100 || wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"),
    { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume",
    hypr.dsp.exec("swayosd-client --output-volume -1 || wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"),
    { locked = true, repeating = true })

-- Mute
hl.bind("XF86AudioMute",    hypr.dsp.exec("swayosd-client --output-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
hl.bind("XF86AudioMicMute", hypr.dsp.exec("swayosd-client --input-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Media playback (XF86 keys)
hl.bind("XF86AudioPlay",  hypr.media.play_pause, { locked = true })
hl.bind("XF86AudioStop",  hypr.media.stop, { locked = true })
hl.bind("XF86AudioPause", hypr.media.pause, { locked = true })
hl.bind("XF86AudioNext",  hypr.media.next, { locked = true })
hl.bind("XF86AudioPrev",  hypr.media.prev, { locked = true })

-- Power / Lock
hl.bind("XF86PowerOff", hypr.dsp.exec("~/.config/wleave/toggle.sh"), { locked = true })
hl.bind("Num_Lock",     hypr.dsp.exec("sleep 0.1 && swayosd-client --num-lock"))

-- Lid switch
hl.bind("switch:on:Lid Switch",  hl.dsp.dpms({action = "on"}),  { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.dpms({action = "off"}), { locked = true })

-- Keyboard backlight
hl.bind("code:238", hypr.dsp.exec("brightnessctl -d platform::kbd_backlight s +1"), { repeating = true, locked = true })
hl.bind("code:237", hypr.dsp.exec("brightnessctl -d platform::kbd_backlight s 1-"), { repeating = true, locked = true })
