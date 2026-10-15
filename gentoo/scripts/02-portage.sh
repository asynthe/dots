#!/usr/bin/env bash
# /etc/portage comes from the repo: ~/git/dots/gentoo/portage is the source, this copies it.
# Copied, not symlinked: portage sources make.conf and env/*.conf as root on every emerge, so a
# symlink into ~ would let anything running as meow become root without sudo.
#
#   ./02-portage.sh          diff: what apply would change in /etc/portage (exit 1 if anything)
#   ./02-portage.sh apply    show the diff, ask, copy repo -> /etc/portage (root-owned)
#   ./02-portage.sh pull     copy /etc/portage -> repo, for what tools wrote there: autounmask
#                            after dispatch-conf, a package's savedconfig. Then commit it.
#
# Only the names that exist in the repo (make.conf, make.profile, env/, package.*/, repos.conf/,
# ...) are touched; /etc/portage's backups, gnupg/ and pending ._cfg* files are left alone.
# Inside those dirs, apply deletes what the repo no longer has, except savedconfig/ (packages
# write it themselves).
set -uo pipefail
[ "$(id -u)" -ne 0 ] || { echo "run as meow, not root"; exit 1; }
P=~/git/dots/gentoo/portage
E=/etc/portage
cd "$P" || exit 1
mapfile -t ITEMS < <(ls -A)
# What pull may bring back: portage's own config names, not backups or gnupg/.
PULLABLE='^(make\.conf|make\.profile|env|bashrc|patches|sets|profile|binrepos\.conf|repos\.conf|savedconfig|package\..+)$'
RSYNC=(rsync -rlc --exclude='._cfg*')

show_diff() {   # $1 from-dir, $2 to-dir: what copying $1 over $2 changes
    local rc=0 x
    for x in "${ITEMS[@]}"; do
        if [ -L "$1/$x" ] || [ -L "$2/$x" ]; then
            [ "$(readlink "$1/$x")" = "$(readlink "$2/$x")" ] ||
                { echo "$x -> $(readlink "$1/$x")   (now: $(readlink "$2/$x"))"; rc=1; }
        elif [ ! -e "$2/$x" ]; then echo "new: $x"; rc=1
        else diff -ru --color=auto --exclude='._cfg*' "$2/$x" "$1/$x" || rc=1
        fi
    done
    return $rc
}

pending() {
    local c; c=$(find $E -name '._cfg*' 2>/dev/null)
    [ -z "$c" ] || printf '\n!! pending in /etc/portage (dispatch-conf, then ./02-portage.sh pull):\n%s\n' "$c"
}

case "${1:-diff}" in
diff)
    show_diff "$P" "$E" && echo "/etc/portage matches the repo"
    ;;
apply)
    if show_diff "$P" "$E"; then echo "/etc/portage already matches the repo"; pending; exit 0; fi
    pgrep -x emerge >/dev/null && echo "!! emerge is running: it keeps the config it started with"
    read -rp "Copy the repo over /etc/portage? [y/N] " a; [ "$a" = y ] || exit 1
    sudo "${RSYNC[@]}" --delete --filter='P /savedconfig/***' --chown=root:root --chmod=D755,F644 \
        "${ITEMS[@]/#/$P/}" $E/ && echo "applied"
    pending
    ;;
pull)
    mapfile -t ITEMS < <(ls -A $E | grep -E "$PULLABLE")
    if show_diff "$E" "$P"; then echo "repo already matches /etc/portage"; exit 0; fi
    read -rp "Copy /etc/portage into the repo? [y/N] " a; [ "$a" = y ] || exit 1
    # As meow (everything here is world-readable), so the repo stays meow's.
    "${RSYNC[@]}" --delete --no-perms "${ITEMS[@]/#/$E/}" "$P/" &&
        git -C "$P" status --short .
    pending
    ;;
*) sed -n '2,15p' "$0" ;;
esac
