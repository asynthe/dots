#!/usr/bin/env bash
# Called by shell.qml with the chosen wallpaper as $1.

# The 5-minute rotation loop started by hyprland.lua would overwrite a hand
# picked wallpaper within the next five minutes, so stop it. It comes back on
# the next Hyprland start, or run ~/.config/hypr/wallpaper.sh & yourself.
pkill -f "$HOME/.config/hypr/wallpaper.sh"

# awww, not swww -- same CLI, and it is the daemon already running.
awww img "$1" --transition-type fade --transition-duration 1
