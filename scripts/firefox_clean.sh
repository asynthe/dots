#! /usr/bin/env bash

set -euo pipefail

APPLY=0
PERMS=0
for a in "$@"; do
    case "$a" in
        --apply)       APPLY=1 ;;
        --permissions) PERMS=1 ;;
        *) echo "unknown flag: $a" >&2; exit 2 ;;
    esac
done

y='\033[1;33m'; g='\033[0;32m'; b='\033[0;34m'; r='\033[0;31m'; nc='\033[0m'
run()  { if [ $APPLY -eq 1 ]; then "$@"; else echo -e "  ${b}would:${nc} $*"; fi; }
note() { echo -e "  ${g}[+]${nc} $*"; }
warn() { echo -e "  ${y}[!]${nc} $*"; }
die()  { echo -e "  ${r}[x]${nc} $*" >&2; exit 1; }

command -v sqlite3 >/dev/null || die "sqlite3 not on PATH (pkgs.sqlite)"

for root in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox"; do
    [ -f "$root/profiles.ini" ] || continue
    rel=$(sed -n 's/^Path=//p' "$root/profiles.ini" | head -1)
    [ -n "$rel" ] && [ -d "$root/$rel" ] && { PROFILE="$root/$rel"; break; }
done
[ -n "${PROFILE:-}" ] || die "no firefox profile found"
echo "── profile ${PROFILE/#$HOME/\~}"

if pgrep -f 'lib/firefox/firefox' >/dev/null 2>&1; then
    die "firefox is running — close it first"
fi
if [ -L "$PROFILE/lock" ]; then
    pid=$(readlink "$PROFILE/lock" | sed 's/.*+//')
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        die "firefox holds the profile lock (pid $pid)"
    fi
    warn "stale lock symlink, ignoring"
fi

KEEP="originAttributes LIKE '%userContextId=%' OR host LIKE '%moz-extension%'"

echo "── cookies"
cdb="$PROFILE/cookies.sqlite"
if [ -f "$cdb" ]; then
    gone=$(sqlite3 "$cdb" "SELECT count(*) FROM moz_cookies WHERE NOT ($KEEP);")
    kept=$(sqlite3 "$cdb" "SELECT count(*) FROM moz_cookies WHERE $KEEP;")
    note "$gone to delete, $kept kept (containers + extensions)"
    if [ $APPLY -eq 1 ]; then
        sqlite3 "$cdb" "DELETE FROM moz_cookies WHERE NOT ($KEEP); VACUUM;"
    else
        echo -e "  ${b}would:${nc} DELETE $gone rows from moz_cookies"
    fi
else
    warn "no cookies.sqlite"
fi

echo "── storage"
sd="$PROFILE/storage/default"
if [ -d "$sd" ]; then
    mapfile -t drop < <(ls -1 "$sd" | grep -v 'userContextId=' | grep -v '^moz-extension' || true)
    kept=$(ls -1 "$sd" | grep -cE 'userContextId=|^moz-extension' || true)
    note "${#drop[@]} origins to drop, $kept kept (containers + extensions)"
    if [ $APPLY -eq 1 ]; then
        for d in "${drop[@]}"; do [ -n "$d" ] && rm -rf "${sd:?}/$d"; done
    else
        for d in "${drop[@]:0:8}"; do echo -e "  ${b}would:${nc} rm $d"; done
        [ "${#drop[@]}" -gt 8 ] && echo -e "  ${b}would:${nc} ... and $(( ${#drop[@]} - 8 )) more"
    fi

    for f in "$PROFILE"/storage.sqlite "$PROFILE"/storage.sqlite-wal "$PROFILE"/storage.sqlite-shm; do
        [ -f "$f" ] && run rm -f "$f"
    done
else
    warn "no storage/default"
fi

if [ $PERMS -eq 1 ]; then
    echo "── permissions"
    pdb="$PROFILE/permissions.sqlite"
    if [ -f "$pdb" ]; then
        q="origin NOT LIKE 'moz-extension%'"
        gone=$(sqlite3 "$pdb" "SELECT count(*) FROM moz_perms WHERE $q;")
        note "$gone permissions to reset"
        [ $APPLY -eq 1 ] && sqlite3 "$pdb" "DELETE FROM moz_perms WHERE $q; VACUUM;"
    fi
fi

echo "── cache"
for c in "$HOME/.cache/mozilla/firefox/$(basename "$PROFILE")"/{cache2,startupCache,thumbnails}; do
    [ -d "$c" ] || continue
    note "$(du -sh "$c" 2>/dev/null | cut -f1) ${c/#$HOME/\~}"
    run rm -rf "$c"
done

echo
[ $APPLY -eq 1 ] && note "done" || warn "dry run — pass --apply"
