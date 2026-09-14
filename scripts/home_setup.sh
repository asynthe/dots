#! /usr/bin/env bash
#
# Builds the $HOME layout from scratch and migrates an old one into it.
# Idempotent — safe to re-run. See ~/git/dots/docs/HOME_STRUCTURE.md.
#
#   ./home_setup.sh          check only, print what would change
#   ./home_setup.sh --apply  do it
#
# The XDG *variables* are set by nix (nix/nixos/desktop/xdg.nix); this script
# only moves the data those variables now point at, and leaves a symlink behind
# for anything that might still be mid-session on the old path.

set -euo pipefail

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

DATA="$HOME/.local/share"
STATE="$HOME/.local/state"
CONF="$HOME/.config"

y='\033[1;33m'; g='\033[0;32m'; b='\033[0;34m'; nc='\033[0m'
run()  { if [ $APPLY -eq 1 ]; then "$@"; else echo -e "  ${b}would:${nc} $*"; fi; }
note() { echo -e "  ${g}[+]${nc} $*"; }
warn() { echo -e "  ${y}[!]${nc} $*"; }

# ─────────────── 1. Skeleton ───────────────
echo "── skeleton"
for d in git ben archive downloads desktop vm wine \
         "$DATA" "$STATE" "$CONF" "$HOME/.cache"; do
    case "$d" in /*) p="$d" ;; *) p="$HOME/$d" ;; esac
    [ -d "$p" ] || { note "mkdir $p"; run mkdir -p "$p"; }
done

# ─────────────── 2. Dotfile → XDG migrations ───────────────
# Each entry: old path : new path. A symlink is left at the old path so
# anything already running (gpg-agent, a shell) keeps working until relogin.
echo "── xdg migrations"
migrate() {
    local old="$1" new="$2"
    [ -e "$old" ] || return 0
    [ -L "$old" ] && return 0            # already migrated
    if [ -e "$new" ]; then warn "$new exists, skipping $old"; return 0; fi
    note "$old -> $new"
    run mkdir -p "$(dirname "$new")"
    run mv "$old" "$new"
    run ln -sfn "$new" "$old"
}

migrate "$HOME/.gnupg"   "$HOME/git/auth/gpg"
migrate "$HOME/.cargo"   "$DATA/cargo"
migrate "$HOME/.rustup"  "$DATA/rustup"
migrate "$HOME/.android" "$DATA/android"
migrate "$HOME/.java"    "$CONF/java"
migrate "$HOME/.kube"    "$CONF/kube"
migrate "$HOME/.npm"     "$HOME/.cache/npm"
migrate "$HOME/.yarn"    "$DATA/yarn"
migrate "$HOME/.nv"      "$HOME/.cache/nv"
migrate "$HOME/.expo"    "$DATA/expo"
migrate "$HOME/.hermes"  "$DATA/hermes"

# the stock prefix, into the wine/prefix/<app> layout it should have had
migrate "$HOME/.wine"    "$HOME/wine/prefix/default"

# gnupg is the one that actually cares about permissions
if [ -d "$HOME/git/auth/gpg" ] && [ $APPLY -eq 1 ]; then
    chmod 700 "$HOME/git/auth/gpg"
    find "$HOME/git/auth/gpg" -type f -exec chmod 600 {} +
    find "$HOME/git/auth/gpg" -type d -exec chmod 700 {} +
fi

# ─────────────── 3. Symlinks into dots ───────────────
# There is no home-manager. Every dotfile reaches $HOME as a symlink from this
# repo, and this is the only place that mapping is written down — if you add a
# directory to config/ it is NOT live until it appears here (or matches the
# name-for-name rule below).
echo "── dots symlinks"

DOTS="$HOME/git/dots"

# Link $2 -> $1. Refuses to clobber real files: a config directory with local
# state in it is someone's data until proven otherwise.
link() {
    local target="$1" name="$2"
    [ -e "$target" ] || { warn "missing in repo: ${target#$DOTS/}"; return 0; }
    if [ -L "$name" ]; then
        [ "$(readlink -f "$name")" = "$(readlink -f "$target")" ] && return 0
        note "relink $(basename "$name") (was $(readlink "$name"))"
    elif [ -e "$name" ]; then
        warn "$(basename "$name") is a real $([ -d "$name" ] && echo dir || echo file), not a symlink — left alone"
        return 0
    else
        note "$(basename "$name") -> ${target#$DOTS/}"
    fi
    run ln -sfn "$target" "$name"
}

# config/<name> -> ~/.config/<name>, for everything that matches name-for-name.
# Listed here rather than globbed so a stray directory in config/ (a backup, a
# half-finished port) does not silently become live config.
CONFIGS=(
    alacritty atuin bash btop cava direnv emacs fuzzel ghostty
    gtk-3.0 gtk-4.0 hypr jj kitty mako mpd mpv ncmpcpp nvim opencode
    qBittorrent quickshell sioyek starship tmux uzdoom
    waybar wezterm yazi zathura zellij zsh
)
for c in "${CONFIGS[@]}"; do
    link "$DOTS/config/$c" "$CONF/$c"
done

# VSCodium is per-file on purpose: ~/.config/VSCodium also holds Cache/,
# Cookies, Crashpad/ and workspaceStorage/. Symlinking the directory hands the
# whole profile to git and breaks the editor.
if [ -d "$CONF/VSCodium/User" ] || [ $APPLY -eq 0 ]; then
    run mkdir -p "$CONF/VSCodium/User"
    for f in settings.json custom.css; do
        link "$DOTS/config/VSCodium/User/$f" "$CONF/VSCodium/User/$f"
    done
fi

# The ones that do not match name-for-name.
link "$DOTS/config/quickshell/tide-island" "$CONF/tide-island"
link "$DOTS/config/zsh/.zshenv"            "$HOME/.zshenv"
link "$DOTS/docs/HOME_STRUCTURE.md"        "$HOME/CLAUDE.md"

# Firefox wants it inside whatever the profile directory is called today.
# The profile lives under ~/.config/mozilla here, not ~/.mozilla — the
# MOZ_LEGACY_PROFILES=0 layout. Both are globbed so this survives either.
for prof in "$CONF"/mozilla/firefox/*.default* "$HOME"/.mozilla/firefox/*.default*; do
    [ -d "$prof" ] || continue
    link "$DOTS/config/firefox/user-overrides.js" "$prof/user-overrides.js"
done

# Cursor/icon themes ship in other/icons, not config/.
for icon in "$DOTS"/other/icons/*; do
    [ -d "$icon" ] || continue
    run mkdir -p "$DATA/icons"
    link "$icon" "$DATA/icons/$(basename "$icon")"
done

# config/powershell is for the Windows/Termux side; ~/git/dots-win/scripts/setup.ps1
# places it. Nothing to do on linux.

# ─────────────── 4. Stray zsh dotfiles ───────────────
# .zshenv is the only zsh file that belongs at $HOME: it is the one thing zsh
# reads before ZDOTDIR exists, and all it does is set ZDOTDIR=~/.config/zsh.
# Everything else zsh wants lives there instead, so anything matching at root
# is a leftover from before ZDOTDIR was set (or from another machine).
echo "── stray zsh dotfiles"

# Regenerable — always safe to drop.
for f in "$HOME"/.zcompdump* "$HOME"/.zsh_sessions "$HOME"/*.zwc; do
    [ -e "$f" ] || continue
    note "rm $(basename "$f") (regenerated)"
    run rm -rf "$f"
done

# Config and history. Empty files and symlinks go; anything with real content
# is left with a warning — it may hold settings worth folding into $ZDOTDIR
# rather than losing.
for f in .zshrc .zprofile .zlogin .zlogout .zsh_history .zhistory; do
    t="$HOME/$f"
    [ -e "$t" ] || [ -L "$t" ] || continue
    if [ -L "$t" ]; then
        note "rm $f (symlink; belongs in \$ZDOTDIR)"
        run rm "$t"
    elif [ -s "$t" ]; then
        warn "$f has content — left alone; fold it into ~/.config/zsh and delete by hand"
    else
        note "rm $f (empty)"
        run rm "$t"
    fi
done

[ -L "$HOME/.zshenv" ] || warn ".zshenv is not a symlink into the repo"

# ─────────────── 5. XDG user dirs ───────────────
# nix writes /etc/xdg/user-dirs.defaults; this applies it now instead of
# waiting for the next login.
echo "── user dirs"
if command -v xdg-user-dirs-update >/dev/null; then
    run xdg-user-dirs-update --force
else
    warn "xdg-user-dirs-update not on PATH"
fi

# ─────────────── 6. Report ───────────────
echo "── check"
[ -d "$HOME/Downloads" ] && warn "~/Downloads still exists (should be ~/downloads)"
[ -d "$HOME/Desktop" ]   && warn "~/Desktop still exists (should be ~/desktop)"
for f in "$HOME"/*; do
    [ -f "$f" ] && [ ! -L "$f" ] && warn "loose file at \$HOME root: $(basename "$f")"
done
# A link into this repo whose source is gone means the config was deleted from
# config/ — the link is dead weight, drop it. Links pointing elsewhere are not
# ours to judge, so they are only reported.
for l in "$CONF"/* "$CONF"/VSCodium/User/* "$DATA"/icons/* \
         "$CONF"/mozilla/firefox/*.default*/user-overrides.js; do
    [ -L "$l" ] && [ -e "$l" ] && continue
    [ -L "$l" ] || continue
    case "$(readlink "$l")" in
        "$DOTS"/*) note "prune dead link $(basename "$l") -> $(readlink "$l")"
                   run rm "$l" ;;
        *)         warn "broken symlink: ${l/#$HOME/\~} -> $(readlink "$l")" ;;
    esac
done
n=$(find "$HOME/git" -maxdepth 2 -name .git -o -maxdepth 2 -name .jj 2>/dev/null | wc -l)
echo -e "  ${g}[+]${nc} $n repos under ~/git"

[ $APPLY -eq 0 ] && echo -e "\n${y}dry run — re-run with --apply${nc}"
exit 0
