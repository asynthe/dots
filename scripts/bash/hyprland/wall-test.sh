#!/usr/bin/env bash

#start swww
WALLPAPERS_DIR=~/dots/wallpaper/dark
WALLPAPER=$(find "$WALLPAPERS_DIR" -type f | fzf --preview='

swww img "$WALLPAPER"
