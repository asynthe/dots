#!/usr/bin/env bash
# Stretch the focused window to its monitor width.
set -euo pipefail

win=$(hyprctl activewindow -j)
mon_id=$(jq -r '.monitor' <<<"$win")
cur_y=$(jq -r '.at[1]' <<<"$win")
cur_h=$(jq -r '.size[1]' <<<"$win")

mon=$(hyprctl monitors -j | jq -r --argjson id "$mon_id" '.[] | select(.id == $id)')
mx=$(jq -r '.x' <<<"$mon")
mw=$(jq -r '(.width / .scale) | floor' <<<"$mon")

hyprctl dispatch "hl.dsp.window.resize({ x = $mw, y = $cur_h })"
hyprctl dispatch "hl.dsp.window.move({ x = $mx, y = $cur_y })"
