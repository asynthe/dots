#!/usr/bin/env bash
set -uo pipefail

PROFILES=(default study work infra)
FF="$HOME/.config/mozilla/firefox"
FIREFOX=$(command -v firefox || command -v firefox-bin) || { notify-send -u critical firefox "firefox not installed"; exit 1; }

usage() { printf 'usage: browser.sh [-p | profile [seed-url...]]\n  no profile: default, -p: pick with fuzzel\nprofiles: %s\n' "${PROFILES[*]}"; }

p=${1:-default}
(($#)) && shift
if [ "$p" = -p ]; then
    p=$(printf '%s\n' "${PROFILES[@]}" | fuzzel --dmenu --prompt 'firefox: ') || exit 0
    [ -n "$p" ] || exit 0
fi
case " ${PROFILES[*]} " in
    *" $p "*) ;;
    *) usage >&2; exit 2 ;;
esac

prof=$(awk -F= -v d="$FF" -v n="$p" '
    function out() { if (name == n && path != "") { print (rel ? d "/" : "") path; exit } }
    /^\[/ { out(); name = ""; path = ""; rel = 1 }
    $1 == "Name" { name = $2 } $1 == "Path" { path = $2 } $1 == "IsRelative" { rel = $2 + 0 }
    END { out() }' "$FF/profiles.ini" 2>/dev/null)
if [ -z "$prof" ]; then
    notify-send -u critical firefox "no profile '$p' — close firefox, run home_setup.sh --apply"
    exit 1
fi

id=firefox
[ "$p" = default ] || id="firefox-$p"

addr=$(hyprctl clients -j | jq -r --arg c "$id" 'first(.[] | select(.class == $c) | .address) // empty')
if [ -n "$addr" ]; then
    if (($#)); then
        ws=$(hyprctl activeworkspace -j | jq .id)
        hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
        exec hyprctl dispatch "hl.dsp.window.move({ workspace = $ws, follow = true })" >/dev/null
    fi
    exec hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
fi

if [ -e "$prof/sessionstore.jsonlz4" ] || [ -e "$prof/sessionstore-backups/recovery.jsonlz4" ]; then
    exec "$FIREFOX" -P "$p" --name "$id"
fi

args=()
if (($#)); then
    args=(--new-window "$1"); shift
    for u; do args+=(--new-tab "$u"); done
fi
exec "$FIREFOX" -P "$p" --name "$id" "${args[@]}"
