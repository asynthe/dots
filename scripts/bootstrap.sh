#! /usr/bin/env bash
#
# First thing to run on a new machine. Clones this repo to ~/git/dots, points
# ~/CLAUDE.md at the $HOME layout doc, then hands off to home_setup.sh.
#
#   curl -fsSL https://gitlab.com/asynthe/dots/-/raw/main/scripts/bootstrap.sh | bash
#   curl -fsSL https://gitlab.com/asynthe/dots/-/raw/main/scripts/bootstrap.sh | bash -s -- --apply
#
# Without --apply, home_setup.sh only prints what it would do. Safe to re-run:
# an existing clone is pulled instead of re-cloned.
#
# No git yet (fresh NixOS)? Prefix with: nix-shell -p git --run '...'

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

# ── clone
# Over https, because a new machine has no ssh key registered anywhere yet.
# The remotes are switched to ssh afterwards so pushing works once it does.
echo "── dots"
mkdir -p "$HOME/git"
if [ -d "$DOTS/.git" ]; then
    git -C "$DOTS" pull --ff-only || warn "pull failed, continuing with what's there"
else
    note "clone -> $DOTS"
    git clone "$HTTPS" "$DOTS"
    # origin fetches from gitlab and pushes to both, gitlab/github for one-offs
    git -C "$DOTS" remote set-url origin "$GITLAB"
    git -C "$DOTS" remote set-url --add --push origin "$GITLAB"
    git -C "$DOTS" remote set-url --add --push origin "$GITHUB"
    git -C "$DOTS" remote add gitlab "$GITLAB"
    git -C "$DOTS" remote add github "$GITHUB"
fi

# ── CLAUDE.md
# Done here rather than left to home_setup.sh, so an agent opened on this
# machine knows the layout even before --apply has been run.
echo "── CLAUDE.md"
doc="$DOTS/docs/HOME_STRUCTURE.md"
if [ -L "$HOME/CLAUDE.md" ] || [ ! -e "$HOME/CLAUDE.md" ]; then
    ln -sfn "$doc" "$HOME/CLAUDE.md"
    note "~/CLAUDE.md -> ${doc/#$HOME/\~}"
else
    warn "~/CLAUDE.md is a real file — left alone; merge it into ${doc/#$HOME/\~} and delete it"
fi

# ── the rest
echo
exec "$DOTS/scripts/home_setup.sh" "$@"
