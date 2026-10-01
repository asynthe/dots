#! /usr/bin/env bash

set -euo pipefail

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

DOTS="$(cd "$(dirname "$0")/../.." && pwd)"
CONF="$HOME/.config"

y='\033[1;33m'; g='\033[0;32m'; b='\033[0;34m'; nc='\033[0m'
run()  { if [ $APPLY -eq 1 ]; then "$@"; else echo -e "  ${b}would:${nc} $*"; fi; }
note() { echo -e "  ${g}[+]${nc} $*"; }
warn() { echo -e "  ${y}[!]${nc} $*"; }

link() {
    local target="$1" name="$2"
    [ "$(readlink "$name" 2>/dev/null)" = "$target" ] && return 0
    [ -e "$name" ] && [ ! -L "$name" ] && { warn "$name is a real file — left alone"; return 0; }
    note "$(basename "$(dirname "$name")")/$(basename "$name") -> ${target#$DOTS/}"
    run ln -sfn "$target" "$name"
}

echo "── firefox profiles"
FF="$CONF/mozilla/firefox"
KEEP="$DOTS/config/firefox/keep.js"

ff_path() {
    awk -F= -v d="$FF" -v n="$1" '
        function out() { if (name == n && path != "") { print (rel ? d "/" : "") path; found = 1; exit } }
        /^\[/ { out(); name = ""; path = ""; rel = 1 }
        $1 == "Name" { name = $2 } $1 == "Path" { path = $2 } $1 == "IsRelative" { rel = $2 + 0 }
        END { if (!found) out() }' "$FF/profiles.ini"
}

if [ -f "$FF/profiles.ini" ]; then
    ff_up=0
    pgrep -f 'lib/firefox/firefox' >/dev/null 2>&1 && ff_up=1

    for name in default study work infra; do
        prof=$(ff_path "$name")
        if [ -z "$prof" ]; then
            if [ $ff_up -eq 1 ]; then
                warn "profile $name missing: close firefox and re-run"
                continue
            fi
            prof="$FF/$name"
            note "create profile $name"
            run firefox --headless --CreateProfile "$name $prof"
        fi
        if [ -f "$prof/user.js" ] && [ ! -L "$prof/user.js" ]; then
            if [ $ff_up -eq 1 ]; then
                warn "$name user.js is generated: close firefox and re-run"
                continue
            fi
            note "rm $name user.js (generated; arkenfox is system-wide now), strip its prefs from prefs.js"
            if [ $APPLY -eq 1 ] && [ -f "$prof/prefs.js" ]; then
                sed -nE 's/^user_pref\("([^"]+)".*/user_pref("\1",/p' "$prof/user.js" | sort -u > "$prof/.managed"
                grep -vF -f "$prof/.managed" "$prof/prefs.js" > "$prof/prefs.js.new" || true
                mv "$prof/prefs.js.new" "$prof/prefs.js"
                rm "$prof/.managed"
            fi
            run rm "$prof/user.js"
            [ $APPLY -eq 1 ] || { echo -e "  ${b}would:${nc} ln -sfn $KEEP $prof/user.js"; continue; }
        fi
        link "$KEEP" "$prof/user.js"
    done

    marked=$(awk -F= '/^\[/ { n = "" } $1 == "Name" { n = $2 } $1 == "Default" && $2 == 1 { print n }' "$FF/profiles.ini")
    if [ "$marked" != default ]; then
        if [ $ff_up -eq 1 ]; then
            warn "default profile is '$marked': close firefox and re-run"
        elif [ $APPLY -eq 1 ]; then
            awk '
                /^\[/ { sec = $0 }
                /^Default=/ && sec ~ /^\[Profile/ { next }
                /^Default=/ && sec ~ /^\[Install/ { print "Default=" path; next }
                { print }
                /^Name=default$/ && sec ~ /^\[Profile/ { print "Default=1" }' path="$(basename "$(ff_path default)")" "$FF/profiles.ini" > "$FF/profiles.ini.new"
            mv "$FF/profiles.ini.new" "$FF/profiles.ini"
            note "default profile: $marked -> default"
        else
            echo -e "  ${b}would:${nc} make default the default profile (was '$marked')"
        fi
    fi
else
    warn "no firefox profiles.ini — start firefox once, then re-run"
fi
