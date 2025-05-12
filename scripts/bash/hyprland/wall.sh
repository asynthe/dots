#!/usr/bin/env bash

# ───────────────────────── Wall script ─────────────────────────
# Load config from .zshrc
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"

# Check for `swww-daemon`
if ! pgrep -x swww-daemon >/dev/null; then
  nohup swww-daemon &>/dev/null &
  disown
  sleep 1
fi

# Wallpaper selection UI
WALLPAPER_FOLDER="${WALLPAPER_FOLDER:-$HOME/dots/wallpaper}"
selected_img=$(fd . "$WALLPAPER_FOLDER" -e jpg -e jpeg -e png -t f \
  | fzf --preview 'kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {}')

# Exit if nothing selected
[[ -z "$selected_img" ]] && exit 0

# NOTE: swww will set up to all monitors by default if monitor not specified.
swww img "$selected_img" \
    #--outputs DP-2 \
    --resize crop \ # no, crop, fit
    --transition-duration 3 \
    --transition-fps 120 \
    --transition-type simple \
    &>/dev/null &

# ───────────────────────── FIX: Others ─────────────────────────
#alias swww-random='~/sync/archive/script/bash/swww/randomize.sh /home/asynthe/sync/system/wallpaper/favourite'
#alias video='fd . $WALLPAPER_VIDEO_FOLDER -e mp4 | sk | xargs mpvpaper -v -p -o "loop-file=inf --no-resume-playback" "*"'
#alias wallp='fd . ~/sync/archive/wallpaper/img -e jpg -e png | sk | tee >(xargs wal -i) >(xargs swww img)'

# --no-resume-playback
# --panscan=1 # (2k zoom)
# '*' -> All monitors

# TODO Check how to run playlist on mpvpaper.
# TODO example of tee >() >() for sending to two commands.
# TODO Check for fzf image preview.

# TESTING
#alias pl='mpvpaper -v -s -o "shuffle loop-playlist=inf" "*" ~/sync/system/wallpaper/video/anime_playlist.m3u'
# alias pl-na='mpvpaper -v -s -o "no-audio shuffle loop-playlist=" "*" ~/sync/system/wallpaper/video/anime_playlist.m3u'
# alias tv-jp='mpvpaper -v -s "*" https://iptv-org.github.io/iptv/countries/jp.m3u'
# alias tv-cl='mpvpaper -v -s "*" https://iptv-org.github.io/iptv/countries/cl.m3u'
# alias tv-au='mpvpaper -v -s "*" https://i.mjh.nz/au/Perth/raw-tv.m3u8'
