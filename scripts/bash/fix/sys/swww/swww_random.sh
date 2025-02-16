#!/usr/bin/env bash
fd . ~/sync/system/wallpaper -e jpg -e png | shuf -n 1 | tee >(xargs wal -i) >(xargs swww img -o eDP-1)
