#!/usr/bin/env bash
# Emerge the package sets in /etc/portage/sets (gentoo/etc/portage/sets, applied by 02-portage.sh).
# Usage: ./03-packages.sh [set ...]   (default: every set except games and tune)
set -uo pipefail
[ "$(id -u)" -ne 0 ] || {
    echo "run as meow, not root"
    exit 1
}
SETS=~/git/dots/gentoo/etc/portage/sets

cli_extras() {
    mkdir -p ~/.local/bin
    curl -fsSL https://raw.githubusercontent.com/nothub/asciiquarium/master/asciiquarium -o ~/.local/bin/asciiquarium
    curl -fsSL https://raw.githubusercontent.com/will8211/unimatrix/master/unimatrix.py -o ~/.local/bin/unimatrix
    chmod +x ~/.local/bin/asciiquarium ~/.local/bin/unimatrix
}

run_set() {
    local s="$1"
    [ "$s" = games ] && {
        echo "games: run ./04-amd64.sh games instead"
        return 0
    }
    [ -f "$SETS/$s" ] || {
        echo "no set '$s' in $SETS"
        return 1
    }
    printf '\n\033[1;34m== @%s (%s packages)\033[0m\n' "$s" "$(wc -l <"$SETS/$s")"
    read -rp "Emerge @$s? [y/N/q] " a
    case $a in
        q) exit 0 ;;
        y) ;;
        *)
            echo skipped
            return 0
            ;;
    esac
    sudo emerge -av --noreplace "@$s" || echo "!! @$s failed or was declined; rerun: $0 $s"
    [ "$s" = cli ] && cli_extras
}

DEFAULT=(base desktop-session desktop-apps fonts hardware cli net dev virt apps pentest)
[ $# -gt 0 ] && DEFAULT=("$@")
for s in "${DEFAULT[@]}"; do run_set "$s"; done

printf '\n\033[1;34m== world entries in no set\033[0m\n'
comm -13 <(cat "$SETS"/* | sort -u) <(sort /var/lib/portage/world)
