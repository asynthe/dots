#! /usr/bin/env bash

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

echo "── skeleton"
# macOS only ever gets git/ -- ben/archive/downloads/desktop/vm/wine are p1's
# lifecycle tiers, not a Mac's; see docs/HOME_STRUCTURE.md.
if [ "$(uname)" = "Darwin" ]; then
    dirs=(git)
else
    dirs=(git ben archive downloads desktop vm wine)
fi
for d in "${dirs[@]}" "$DATA" "$STATE" "$CONF" "$HOME/.cache"; do
    case "$d" in /*) p="$d" ;; *) p="$HOME/$d" ;; esac
    [ -d "$p" ] || { note "mkdir $p"; run mkdir -p "$p"; }
done

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

migrate "$HOME/.wine"    "$HOME/wine/prefix/default"

if [ -d "$HOME/git/auth/gpg" ] && [ $APPLY -eq 1 ]; then
    chmod 700 "$HOME/git/auth/gpg"
    find "$HOME/git/auth/gpg" -type f -exec chmod 600 {} +
    find "$HOME/git/auth/gpg" -type d -exec chmod 700 {} +
fi

echo "── dots symlinks"

DOTS="$HOME/git/dots"

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

CONFIGS=(
    alacritty atuin bash btop cava direnv emacs fuzzel ghostty
    gtk-3.0 gtk-4.0 hypr jj kitty mako mpd mpv ncmpcpp nvim opencode
    qBittorrent quickshell sioyek starship tmux uzdoom
    wezterm yazi zathura zellij zsh
)
for c in "${CONFIGS[@]}"; do
    link "$DOTS/config/$c" "$CONF/$c"
done

if [ -d "$CONF/VSCodium/User" ] || [ $APPLY -eq 0 ]; then
    run mkdir -p "$CONF/VSCodium/User"
    for f in settings.json custom.css; do
        link "$DOTS/config/VSCodium/User/$f" "$CONF/VSCodium/User/$f"
    done
fi

link "$DOTS/config/zsh/.zshenv"            "$HOME/.zshenv"
link "$DOTS/docs/HOME_STRUCTURE.md"        "$HOME/CLAUDE.md"

for prof in "$CONF"/mozilla/firefox/*.default* "$HOME"/.mozilla/firefox/*.default*; do
    [ -d "$prof" ] || continue
    link "$DOTS/config/firefox/user-overrides.js" "$prof/user-overrides.js"
done

for icon in "$DOTS"/assets/icons/*; do
    [ -d "$icon" ] || continue
    run mkdir -p "$DATA/icons"
    link "$icon" "$DATA/icons/$(basename "$icon")"
done

for wrap in "$DOTS"/scripts/bin/*; do
    [ -f "$wrap" ] || continue
    run mkdir -p "$HOME/.local/bin"
    link "$wrap" "$HOME/.local/bin/$(basename "$wrap")"
done

echo "── stray zsh dotfiles"

for f in "$HOME"/.zcompdump* "$HOME"/.zsh_sessions "$HOME"/*.zwc; do
    [ -e "$f" ] || continue
    note "rm $(basename "$f") (regenerated)"
    run rm -rf "$f"
done

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

echo "── user dirs"
if command -v xdg-user-dirs-update >/dev/null; then
    run xdg-user-dirs-update --force
else
    warn "xdg-user-dirs-update not on PATH"
fi

echo "── check"
# macOS ties ~/Desktop and ~/Downloads to Finder/Spotlight/screenshots -- unlike
# Linux, they're not just a folder you can rename away, so don't nag about them.
if [ "$(uname)" != "Darwin" ]; then
    [ -d "$HOME/Downloads" ] && warn "~/Downloads still exists (should be ~/downloads)"
    [ -d "$HOME/Desktop" ]   && warn "~/Desktop still exists (should be ~/desktop)"
fi
for f in "$HOME"/*; do
    [ -f "$f" ] && [ ! -L "$f" ] && warn "loose file at \$HOME root: $(basename "$f")"
done
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
