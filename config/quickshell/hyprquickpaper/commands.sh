#!/usr/bin/env bash
# Called by shell.qml with the chosen wallpaper as $1. See ~/git/dots/docs/WALLPAPER.md.

exec "$HOME/.config/hypr/wallpaper.sh" --set "$1"
