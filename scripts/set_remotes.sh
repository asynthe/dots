#! /usr/bin/env bash

# Make every repo under the git root push to both gitlab and github, the way
# bootstrap.sh sets up dots: origin fetches from its current url and pushes to
# every host that has the repo, plus a named remote per host.
# A host is only added if it already has asynthe/<name> (ls-remote answers).

set -uo pipefail

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) GIT_ROOT="$HOME/Desktop/git" ;;  # Windows, Git Bash
    *)                    GIT_ROOT="$HOME/git" ;;
esac
HOSTS=(gitlab github)

export GIT_TERMINAL_PROMPT=0
# Extend, don't replace: ~/.gitconfig's sshCommand is what picks the key.
export GIT_SSH_COMMAND="$(git config core.sshCommand || echo ssh) -o BatchMode=yes -o ConnectTimeout=10"

y='\033[1;33m'; g='\033[0;32m'; b='\033[0;34m'; nc='\033[0m'
run()  { if [ $APPLY -eq 1 ]; then "$@"; else echo -e "  ${b}would:${nc} $*"; fi; }
note() { echo -e "  ${g}[+]${nc} $*"; }
warn() { echo -e "  ${y}[!]${nc} $*"; }

for repo in "$GIT_ROOT"/*/; do
    repo="${repo%/}"
    [ -e "$repo/.git" ] || continue
    name="$(basename "$repo")"
    echo "── $name"

    if ! git -C "$repo" remote get-url origin &>/dev/null; then
        warn "no origin, skipping"
        continue
    fi

    want=()
    for h in "${HOSTS[@]}"; do
        url="git@$h.com:asynthe/$name.git"
        if git ls-remote --heads "$url" &>/dev/null; then
            want+=("$url")
            if [ "$(git -C "$repo" remote get-url "$h" 2>/dev/null)" != "$url" ]; then
                note "remote $h -> $url"
                if git -C "$repo" remote get-url "$h" &>/dev/null; then
                    run git -C "$repo" remote set-url "$h" "$url"
                else
                    run git -C "$repo" remote add "$h" "$url"
                fi
            fi
        else
            warn "not on $h"
        fi
    done

    [ ${#want[@]} -gt 0 ] || continue
    have="$(git -C "$repo" config --get-all remote.origin.pushurl | tr '\n' ' ')"
    [ "$have" = "${want[*]} " ] && continue

    note "origin pushes to: ${want[*]}"
    run git -C "$repo" config --unset-all remote.origin.pushurl
    for url in "${want[@]}"; do
        run git -C "$repo" remote set-url --add --push origin "$url"
    done
done

[ $APPLY -eq 1 ] || echo -e "\ndry run, pass --apply to make changes"
