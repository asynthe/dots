#!/usr/bin/env bash
set -uo pipefail

STATE="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/current-video-wallpaper"
MPV_OPTS="no-audio loop"

stop() {
    pkill -x mpvpaper 2>/dev/null
}

if [[ ${1:-} == --stop ]]; then
    stop
    rm -f "$STATE"
    exit 0
fi

if [[ ${1:-} == --set ]]; then
    f=${2:?--set needs a file}
    [[ -f $f ]] || exit 1
    stop
    sleep 0.2
    mpvpaper -f -p -o "$MPV_OPTS" ALL "$f" || exit 1
    mkdir -p "${STATE%/*}"
    printf '%s\n' "$f" >"$STATE"
    exit 0
fi

# No args: restore the last video wallpaper (session startup). No-op if
# none was ever set — plain wallpaper.sh / awww stays the background then.
f=$(cat "$STATE" 2>/dev/null)
[[ -f ${f:-} ]] || exit 0
pgrep -x mpvpaper >/dev/null && exit 0
mpvpaper -f -p -o "$MPV_OPTS" ALL "$f"
