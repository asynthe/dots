#!/usr/bin/env bash
# Install the remaining packages.md blocks, read straight from packages.md (its source of truth).
# For each block: shows the emerge (and "before" lines, if a block has any), asks, then runs it.
# Its USE flags and keywords are already in /etc/portage (gentoo/portage, via 02-portage.sh).
# emerge is -av, so you still confirm every list. Usage: ./03-packages.sh [block ...]   (default: all)
set -uo pipefail
[ "$(id -u)" -ne 0 ] || { echo "run as meow, not root"; exit 1; }
MD=~/git/dots/gentoo/packages.md

# Code blocks of one "## <name>" section: before (after a "before" line) and the emerge one.
block() {   # $1 section, $2 before|emerge
    awk -v sec="$1" -v want="$2" '
        /^## / { insec = (substr($0,4) == sec); next }
        !insec { next }
        /^before/ { nextbefore = 1 }
        /^```bash/ { inb = 1; buf = ""; next }
        /^```/ && inb { inb = 0
            if (want == "before" && nextbefore) { printf "%s", buf; exit }
            if (want == "emerge" && buf ~ /emerge -av --noreplace/) { printf "%s", buf; exit }
            nextbefore = 0; next }
        inb { buf = buf $0 "\n" }' "$MD"
}

run_block() {
    local sec="$1" before emerge
    # games has two dependency loops to break first (packages.md, games).
    [ "$sec" = games ] && { echo "games: run ./04-amd64.sh games instead"; return 0; }
    before=$(block "$sec" before); emerge=$(block "$sec" emerge)
    [ -n "$emerge" ] || { echo "no emerge block for '$sec'"; return 1; }
    printf '\n\033[1;34m== %s\033[0m\n' "$sec"
    [ -n "$before" ] && printf '\033[2mbefore:\n%s\033[0m\n' "$before"
    printf '\033[2m%s\033[0m\n' "$emerge"
    read -rp "Run '$sec'? [y/N/q] " a
    case $a in q) exit 0 ;; y) ;; *) echo skipped; return 0 ;; esac
    [ -n "$before" ] && bash -ec "$before"
    bash -c "$emerge" || echo "!! '$sec' emerge failed or was declined; rerun: $0 '$sec'"
}

BLOCKS=("base" "hardware" "cli" "net" "dev" "virt" "apps" "pentest (optional)")
[ $# -gt 0 ] && BLOCKS=("$@")
for b in "${BLOCKS[@]}"; do run_block "$b"; done

printf '\n\033[1;34m== check (packages.md): world entries not in packages.md\033[0m\n'
comm -13 <(grep -oE '^  [a-z0-9-]+/[^ ]+' "$MD" | tr -d ' ' | sort -u) <(sort /var/lib/portage/world)
