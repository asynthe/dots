#!/usr/bin/env bash
# Launches ghostty, then nudges the cursor to force Hyprland to re-check
# focus-under-cursor — works around a known Hyprland quirk where a newly
# mapped window doesn't actually receive keyboard input until the mouse
# physically moves (no pointer motion event = no focus re-evaluation).
ghostty &
sleep 0.15
pos=$(hyprctl cursorpos)
x=${pos%%,*}
y=${pos##*, }
hyprctl dispatch "hl.dsp.cursor.move({x=$x, y=$y})"
