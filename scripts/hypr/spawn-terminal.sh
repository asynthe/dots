#!/usr/bin/env bash
# Hyprland only gives a new window keyboard focus after pointer motion.
ghostty &
sleep 0.15
pos=$(hyprctl cursorpos)
x=${pos%%,*}
y=${pos##*, }
hyprctl dispatch "hl.dsp.cursor.move({x=$x, y=$y})"
