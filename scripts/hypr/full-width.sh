#!/usr/bin/env bash
# Resizes the currently focused (floating) window to span the full width of
# its monitor, keeping its current height and vertical position in place.
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
