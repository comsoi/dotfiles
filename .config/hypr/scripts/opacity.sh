#!/bin/bash
# Adjust the active window's opacity, with blur fading in tandem:
# opacity 1.0 -> full base blur, opacity 0.1 -> no blur.
# Usage: opacity.sh <delta>   e.g. opacity.sh 0.05 / opacity.sh -0.05
#
# Implementation: tag the window with its opacity value and apply a named
# window rule `opacity = "v v override"`, so focused and unfocused states
# render identically (a plain set_prop is dropped from rendering on focus
# loss). One rule per value is created lazily; re-tagging moves a window
# between them.

addr=$(hyprctl -j activewindow | jq -r '.address')
if [ -z "$addr" ] || [ "$addr" = "null" ]; then
    exit 0
fi

# Per-window opacity state (survives rule re-creation; getprop does not
# reflect rule values)
STATE_OP="${XDG_RUNTIME_DIR:-/tmp}/hypr-opacity-state"
touch "$STATE_OP"

# Drop state of closed windows
hyprctl -j clients | jq -r '.[].address' | sort > "$STATE_OP.live"
awk 'NR==FNR{live[$1]=1; next} live[$1]' "$STATE_OP.live" "$STATE_OP" > "$STATE_OP.tmp"
mv "$STATE_OP.tmp" "$STATE_OP"
rm -f "$STATE_OP.live"

cur=$(awk -v a="$addr" '$1==a{print $2}' "$STATE_OP" | tail -1)
if [ -z "$cur" ]; then
    cur=$(hyprctl getprop "address:$addr" opacity 2>/dev/null)
fi
case "$cur" in
    ''|*[!0-9.]*) cur=1.0 ;;
esac

new=$(awk -v c="$cur" -v d="$1" 'BEGIN {
    n = c + d
    if (n < 0.1) n = 0.1
    if (n > 1)   n = 1
    printf "%.2f", n
}')

# Apply the value both ways (measured on v0.56.2):
# - set_prop renders immediately while the window is focused (rules only
#   take visual effect on focus change, so prop is what makes the scroll
#   preview work on the focused window)
# - the tag + rule `v v override` is what keeps the same value once the
#   window loses focus (props are ignored for rendering when unfocused)
# The two never multiply: focused renders prop only, unfocused rule only.
hyprctl dispatch "hl.dsp.window.clear_tags()" >/dev/null
hyprctl dispatch "hl.dsp.window.tag({ tag = 'op-$new' })" >/dev/null
hyprctl eval "hl.window_rule({ name = 'op-rule-$new', match = { tag = 'op-$new' }, opacity = '$new $new override' })" >/dev/null
hyprctl eval "hl.exec_scheduled_prop_refresh_immediately()" >/dev/null
hyprctl dispatch "hl.dsp.window.set_prop({ prop = 'opacity', value = '$new' })" >/dev/null

grep -v "^$addr " "$STATE_OP" > "$STATE_OP.tmp"
echo "$addr $new" >> "$STATE_OP.tmp"
mv "$STATE_OP.tmp" "$STATE_OP"

# Blur factor in [0, 1]: 0 at min opacity (no blur), 1 at full opacity (base blur)
factor=$(awk -v o="$new" 'BEGIN {
    f = (o - 0.1) / 0.9
    if (f < 0) f = 0
    if (f > 1) f = 1
    printf "%.4f", f
}')

# Remember the base blur settings (first run only)
STATE="${XDG_RUNTIME_DIR:-/tmp}/hypr-opacity-blur-base"
if [ ! -f "$STATE" ]; then
    {
        hyprctl getoption decoration:blur:size -j   | jq -r '"size=\(.int)"'
        hyprctl getoption decoration:blur:passes -j | jq -r '"passes=\(.int)"'
    } > "$STATE"
fi
. "$STATE"

blur=$(awk -v b="$size" -v p="$passes" -v f="$factor" 'BEGIN {
    s = int(b * f + 0.5)
    n = int(p * f + 0.5)
    printf "%d %d", s, n
}')
set -- $blur

if [ "$1" -le 0 ] || [ "$2" -le 0 ]; then
    hyprctl eval "hl.config({ decoration = { blur = { enabled = false } } })" >/dev/null
else
    hyprctl eval "hl.config({ decoration = { blur = { enabled = true, size = $1, passes = $2 } } })" >/dev/null
fi

# Back at full opacity the base blur is restored; re-sync the stored base
# with the live config in case it changed meanwhile
if [ "$factor" = "1.0000" ]; then
    {
        hyprctl getoption decoration:blur:size -j   | jq -r '"size=\(.int)"'
        hyprctl getoption decoration:blur:passes -j | jq -r '"passes=\(.int)"'
    } > "$STATE"
fi
