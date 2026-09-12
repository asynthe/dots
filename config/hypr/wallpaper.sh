#!/usr/bin/env bash
# Usage: wallpaper.sh | wallpaper.sh --set FILE [FADE]   -- see docs/WALLPAPER.md
set -uo pipefail

STATE="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/current-wallpaper"
DEFAULT="$HOME/git/dots/wallpaper/3440x1440"

if [[ ${1:-} == --set ]]; then
    f=${2:?--set needs a file}
    [[ -f $f ]] || exit 1
    awww img "$f" --transition-type fade --transition-duration "${3:-1}" || exit 1
    mkdir -p "${STATE%/*}"
    printf '%s\n' "$f" > "$STATE"
    exit 0
fi

# No argument: restore the last pick at login, or fall back to any still.
f=$(cat "$STATE" 2>/dev/null)
[[ -f ${f:-} ]] || f=$(find "$DEFAULT" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort | head -n1)
[[ -f ${f:-} ]] || exit 0

for _ in {1..10}; do
    awww img "$f" --transition-type none && break
    sleep 0.5
done
