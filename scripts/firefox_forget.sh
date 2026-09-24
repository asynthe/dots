#! /usr/bin/env bash

set -euo pipefail

APPLY=0
COOKIES=0
CONTAINERS=0
DOMAINS=()
for a in "$@"; do
    case "$a" in
        --apply)      APPLY=1 ;;
        --cookies)    COOKIES=1 ;;
        --containers) CONTAINERS=1 ;;
        -*) echo "unknown flag: $a" >&2; exit 2 ;;
        *)  DOMAINS+=("$a") ;;
    esac
done
[ ${#DOMAINS[@]} -gt 0 ] || { echo "usage: $0 [--apply] [--cookies] [--containers] <domain>..." >&2; exit 2; }

y='\033[1;33m'; g='\033[0;32m'; b='\033[0;34m'; r='\033[0;31m'; nc='\033[0m'
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
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && die "firefox holds the profile lock (pid $pid)"
    warn "stale lock symlink, ignoring"
fi

revstr() { echo "$1" | awk '{ for (i=length(); i>0; i--) printf substr($0,i,1); print "" }'; }

place_where=""; cookie_where=""
for d in "${DOMAINS[@]}"; do
    rh=$(revstr "$d")
    place_where+="${place_where:+ OR }rev_host LIKE '${rh}.%'"
    cookie_where+="${cookie_where:+ OR }(host = '${d}' OR host LIKE '%.${d}'"
    cookie_where+=" OR instr(originAttributes, 'partitionKey=%28https%2C${d}') > 0)"
done

echo "── history"
pdb="$PROFILE/places.sqlite"
[ -f "$pdb" ] || die "no places.sqlite"

read -r hits keep < <(sqlite3 -separator ' ' "$pdb" \
    "SELECT count(*), sum(foreign_count > 0) FROM moz_places WHERE $place_where;")
keep=${keep:-0}
visits=$(sqlite3 "$pdb" \
    "SELECT count(*) FROM moz_historyvisits WHERE place_id IN (SELECT id FROM moz_places WHERE $place_where);")
note "${DOMAINS[*]}: $hits pages, $visits visits"
note "$(( hits - keep )) pages deleted, $keep kept as bookmarks (visits stripped)"

if [ "$hits" -eq 0 ]; then
    warn "nothing to forget"
elif [ $APPLY -eq 1 ]; then
    sqlite3 "$pdb" <<SQL
BEGIN;
CREATE TEMP TABLE victims AS SELECT id FROM moz_places WHERE $place_where;

DELETE FROM moz_historyvisits_extra
      WHERE visit_id IN (SELECT id FROM moz_historyvisits
                          WHERE place_id IN (SELECT id FROM victims));
DELETE FROM moz_historyvisits  WHERE place_id IN (SELECT id FROM victims);
DELETE FROM moz_places_metadata
      WHERE place_id IN (SELECT id FROM victims)
         OR referrer_place_id IN (SELECT id FROM victims);
DELETE FROM moz_inputhistory   WHERE place_id IN (SELECT id FROM victims);
DELETE FROM moz_annos          WHERE place_id IN (SELECT id FROM victims);
DELETE FROM moz_places_extra   WHERE place_id IN (SELECT id FROM victims);

-- Bookmarked: keep the row, erase that it was ever visited. recalc_frecency
-- makes Firefox rebuild the ranking instead of trusting the stale number.
UPDATE moz_places SET visit_count = 0, last_visit_date = NULL,
                      frecency = -1, recalc_frecency = 1
      WHERE id IN (SELECT id FROM victims) AND foreign_count > 0;
DELETE FROM moz_places
      WHERE id IN (SELECT id FROM victims) AND foreign_count = 0;

-- This schema has no triggers, so the origins index is ours to tidy.
DELETE FROM moz_origins
      WHERE id NOT IN (SELECT DISTINCT origin_id FROM moz_places
                        WHERE origin_id IS NOT NULL);
DROP TABLE victims;
COMMIT;
VACUUM;
SQL
else
    echo -e "  ${b}would:${nc} DELETE $(( hits - keep )) rows from moz_places, $visits from moz_historyvisits"
fi

if [ $COOKIES -eq 1 ]; then
    echo "── cookies"
    cdb="$PROFILE/cookies.sqlite"
    scope="AND originAttributes NOT LIKE '%userContextId=%'"
    [ $CONTAINERS -eq 1 ] && scope=""
    [ $CONTAINERS -eq 1 ] && warn "--containers: container logins for these domains go too"

    if [ -f "$cdb" ]; then
        n=$(sqlite3 "$cdb" "SELECT count(*) FROM moz_cookies WHERE ($cookie_where) $scope;")
        note "$n cookies to delete"
        if [ $APPLY -eq 1 ]; then
            sqlite3 "$cdb" "DELETE FROM moz_cookies WHERE ($cookie_where) $scope; VACUUM;"
        else
            echo -e "  ${b}would:${nc} DELETE $n rows from moz_cookies"
        fi
    fi

    echo "── storage"
    sd="$PROFILE/storage/default"
    if [ -d "$sd" ]; then
        pat=$(printf '%s\n' "${DOMAINS[@]}" | sed 's/\./\\./g' | paste -sd'|')
        own="\\+\\+\\+([^^]*\\.)?($pat)"
        part="partitionKey=%28https%2C($pat)"
        if [ $CONTAINERS -eq 1 ]; then
            mapfile -t drop < <(ls -1 "$sd" | grep -E "${own}(\^|$)|$part" || true)
        else
            mapfile -t drop < <(ls -1 "$sd" | grep -v 'userContextId=' \
                              | grep -E "${own}$|$part" || true)
        fi
        note "${#drop[@]} storage origins to drop"
        if [ $APPLY -eq 1 ]; then
            for d in "${drop[@]}"; do [ -n "$d" ] && rm -rf "${sd:?}/$d"; done
            rm -f "$PROFILE"/storage.sqlite "$PROFILE"/storage.sqlite-wal "$PROFILE"/storage.sqlite-shm
        else
            for d in "${drop[@]:0:8}"; do echo -e "  ${b}would:${nc} rm $d"; done
            [ "${#drop[@]}" -gt 8 ] && echo -e "  ${b}would:${nc} ... and $(( ${#drop[@]} - 8 )) more"
        fi
    fi
fi

echo
[ $APPLY -eq 1 ] && note "done" || warn "dry run — pass --apply"
