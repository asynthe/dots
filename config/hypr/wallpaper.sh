#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/dots/wallpaper/3440x1440"

# Wait for awww-daemon to be ready
sleep 2

while true; do
    img=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | shuf -n1)
    if [ -n "$img" ]; then
        awww img "$img" --transition-type fade --transition-duration 2
    fi
    sleep 300
done
