#! /usr/bin/env bash

set -euo pipefail

DOTS="$HOME/git/dots"
HTTPS="https://gitlab.com/asynthe/dots.git"
GITLAB="git@gitlab.com:asynthe/dots.git"
GITHUB="git@github.com:asynthe/dots.git"

y='\033[1;33m'; g='\033[0;32m'; r='\033[0;31m'; nc='\033[0m'
note() { echo -e "  ${g}[+]${nc} $*"; }
warn() { echo -e "  ${y}[!]${nc} $*"; }

command -v git >/dev/null || {
    echo -e "  ${r}[x]${nc} git not found — try: nix-shell -p git --run 'curl -fsSL ... | bash'"
    exit 1
}

echo "── dots"
mkdir -p "$HOME/git"
if [ -d "$DOTS/.git" ]; then
    git -C "$DOTS" pull --ff-only || warn "pull failed, continuing with what's there"
else
    note "clone -> $DOTS"
    git clone "$HTTPS" "$DOTS"
    git -C "$DOTS" remote set-url origin "$GITLAB"
    git -C "$DOTS" remote set-url --add --push origin "$GITLAB"
    git -C "$DOTS" remote set-url --add --push origin "$GITHUB"
    git -C "$DOTS" remote add gitlab "$GITLAB"
    git -C "$DOTS" remote add github "$GITHUB"
fi

echo "── CLAUDE.md"
doc="$DOTS/docs/HOME_STRUCTURE.md"
if [ -L "$HOME/CLAUDE.md" ] || [ ! -e "$HOME/CLAUDE.md" ]; then
    ln -sfn "$doc" "$HOME/CLAUDE.md"
    note "~/CLAUDE.md -> ${doc/#$HOME/\~}"
else
    warn "~/CLAUDE.md is a real file — left alone; merge it into ${doc/#$HOME/\~} and delete it"
fi

echo
exec "$DOTS/scripts/home_setup.sh" "$@"
