#!/usr/bin/env bash
# The from-source system on the repo's portage config (~amd64, LTO, lto pgo),
# then the extras. /etc/portage must match gentoo/etc/portage first (./02-portage.sh apply).
#
#   ./04-amd64.sh prep     build-in-RAM (tmpfs). Run the rest from a text console (tty2 + tmux),
#                          not a terminal inside Hyprland: that one dies with the session.
#   ./04-amd64.sh world    sync, gcc (graphite lto pgo) first, then emerge -e @world: the stage3
#                          and binhost packages rebuilt on ~amd64 with LTO. Many hours. Reboot.
#   ./04-amd64.sh resume   continue an interrupted emerge (portage's saved queue), same inhibit + log.
#   ./04-amd64.sh failed   packages that failed -> no-lto (in the repo), apply, rebuild them.
#   ./04-amd64.sh games    the games set (interactive: Steam autounmask, two dependency loops).
#   ./04-amd64.sh hyprglass  rebuild the hyprglass plugin (after any Hyprland update).
#
# Watch from another tty: `tail -f ~/.local/state/p1-setup/logs/*.log` (newest one).
set -uo pipefail
[ "$(id -u)" -ne 0 ] || { echo "run as meow, not root"; exit 1; }
S=~/git/dots/gentoo/scripts
P=~/git/dots/gentoo/etc/portage
applied() { "$S/02-portage.sh" diff >/dev/null || { echo "/etc/portage differs from the repo: $S/02-portage.sh apply"; exit 1; }; }
step() { printf '\n\033[1;34m== %s\033[0m\n' "$*"; }

# sudo once, kept alive for the whole run (the emerges outlast sudo's 5 min).
sudo -v || exit 1
( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done ) &

atoms() { grep -v '^#' ~/git/dots/gentoo/etc/portage/sets/"$1"; }

hyprglass() {
    step "rebuild hyprglass against the new Hyprland"
    [ -d ~/.cache/hyprglass ] || git clone --branch v0.7.0 --depth 1 https://github.com/hyprnux/hyprglass ~/.cache/hyprglass
    make -C ~/.cache/hyprglass clean
    make -C ~/.cache/hyprglass CXX=g++ INCLUDES="$(pkg-config --cflags hyprland pixman-1 libdrm lua5.4)" &&
        sudo install -Dm755 ~/.cache/hyprglass/hyprglass.so /usr/local/lib/libhyprglass.so
}

# Long root commands: no sleep/idle/lid-suspend while they run, output also in ~/.local/state/p1-setup/logs.
LOG=~/.local/state/p1-setup/logs/$(date +%F-%H%M)-${1:-none}.log
long() {
    mkdir -p ~/.local/state/p1-setup/logs
    touch "$LOG"   # created as meow, so script(1) running as root only appends to it
    echo "+ $*"
    # Full power, only for these runs (make.conf keeps the everyday --jobs=2): a third package in
    # parallel (the load average still gates it), and the "performance" power profile held while
    # emerge lives (back to the old one after).
    # No MAKEOPTS here: an environment MAKEOPTS beats package.env, so heavy.conf's -j8 was ignored
    # and qtwebengine's check-reqs asked for 22 jobs x 2.5G = 55G and refused (2026-10-15).
    # make.conf's -j15 applies, package.env overrides it per package (heavy: -j8).
    local pp=(); command -v powerprofilesctl >/dev/null &&   # not installed yet at setup §0
        pp=(powerprofilesctl launch -p performance -r "emerge (04-amd64.sh)" --)
    local power=(EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=24 --with-bdeps=y")
    # Own system scope with OOMPolicy=continue: inside the login session's scope, one compiler
    # killed by the OOM killer made systemd stop the whole scope (shell, emerge, the lot). Now
    # only that package fails, and --keep-going moves on.
    # script(1) copies the terminal to the log; piping emerge itself would buffer its Yes/No prompt.
    sudo systemd-run --scope --quiet --collect --unit="p1-emerge-$(date +%s)" \
        --property=OOMPolicy=continue \
        systemd-inhibit --what=sleep:idle:handle-lid-switch --who=p1-rebuild \
        --why="emerge running (04-amd64.sh)" \
        "${pp[@]}" \
        script -qefa "$LOG" -c "$(printf '%q ' env "${power[@]}" "$@")"
}

snapshot() {   # read-only btrfs snapshot of / (subvol @) before a big rebuild
    # Once per stage: a rerun must not replace the real "before" state.
    ls -d /.snapshots/@-$1-* >/dev/null 2>&1 && { echo "snapshot: kept $(ls -d /.snapshots/@-$1-* | head -1)"; return; }
    local n="/.snapshots/@-$1-$(date +%F-%H%M)"
    sudo btrfs subvolume snapshot -r / "$n" && echo "snapshot: $n"
}

case "${1:-}" in
prep)
    step "build in RAM: /var/tmp/portage on tmpfs (24G), big packages build on disk"
    sudo mkdir -p /var/tmp/portage /var/tmp/notmpfs
    sudo chown portage:portage /var/tmp/notmpfs
    grep -q ' /var/tmp/portage ' /etc/fstab || echo 'tmpfs  /var/tmp/portage  tmpfs  size=24G,uid=portage,gid=portage,mode=775,noatime  0 0' | sudo tee -a /etc/fstab
    sudo systemctl daemon-reload
    findmnt /var/tmp/portage >/dev/null || sudo mount /var/tmp/portage
    # Builds that need more than ~16G of build dir go to disk: package.env/notmpfs (repo).
    findmnt /var/tmp/portage

    # No FEATURES=buildpkg: with binpkg-request-signature, portage rejects its own unsigned
    # binpkgs and every build fails at install. Rollback is the btrfs snapshot instead.

    echo; echo "Now: CTRL+ALT+F2, log in as meow, tmux new -s world, '$S/04-amd64.sh world'"
    ;;

world)
    findmnt /var/tmp/portage >/dev/null || { echo "run './04-amd64.sh prep' first"; exit 1; }
    applied
    step "sync: gentoo + the overlays in repos.conf (guru, hyproverlay, steam-overlay)"
    sudo emaint sync -a
    step "news (skim; q to quit)"
    eselect news read new | less
    snapshot pre-world

    # gcc first, so everything after is built by the graphite/lto/pgo one (package.use/p1).
    step "gcc (graphite lto pgo), then switch to its newest slot"
    long emerge -av1 --keep-going sys-devel/gcc
    sudo gcc-config "$(gcc-config -l | wc -l)" && gcc-config -c

    step "rebuild everything (-e @world): ~amd64 versions, LTO, the profile's flags"
    echo "After your 'Yes' it runs unattended. Sleep, idle and the lid switch are blocked meanwhile."
    long USE=-gpm emerge -ave --keep-going --backtrack=50 @world
    step "gpm back (ncurses, gpm and what links them)"
    long emerge -avuDN --keep-going --backtrack=50 @world
    echo; echo "Failed ones: ./04-amd64.sh failed. Then: sudo emerge -av @preserved-rebuild,"
    echo "sudo dispatch-conf (z for files you edited), check sudo -v, reboot into the new kernel."
    ;;

resume)
    long emerge --resume --keep-going
    ;;

hyprglass) hyprglass ;;

games)
    # Separate, interactive: Steam's 32-bit deps need autounmask + dispatch-conf, and the
    # gpm <-> ncurses loop needs the -gpm rebuild first.
    applied
    mapfile -t GAMES < <(atoms games)
    G=(--getbinpkg=n --usepkg=n --noreplace --backtrack=50)
    # Steam's abi_x86_32 list is already in package.use/zz-autounmask (repo); this only catches
    # what newer versions add. Autounmask writes to the last file in package.use: zz-autounmask.
    step "games: autounmask (anything new), dispatch-conf: u, then back into the repo"
    long emerge -a "${G[@]}" --autounmask-only --autounmask-write "${GAMES[@]}" || true
    sudo dispatch-conf
    "$S/02-portage.sh" pull
    # Both loops only break once the 32-bit flags above are set.
    step "loops: ncurses without gpm (64 + 32-bit), mono minimal"
    long USE=-gpm emerge -av1 sys-libs/ncurses
    [ -n "$(qlist -IC dev-lang/mono)" ] || long USE=minimal emerge -av1 dev-lang/mono
    step "games (${#GAMES[@]} packages)"
    long emerge -av "${G[@]}" --keep-going "${GAMES[@]}"
    step "world again (puts gpm back, full mono)"
    long emerge -avuDN --getbinpkg=n --usepkg=n --backtrack=50 --keep-going @world
    ;;

failed)
    # A failed build leaves /var/tmp/portage/<cat>/<pkg-ver>/temp/build.log behind; successful
    # ones are cleaned. Those are the failures: retry them without LTO, and remember them.
    mapfile -t F < <(sudo find /var/tmp/portage -mindepth 4 -maxdepth 4 -path '*/temp/build.log' \
        | awk -F/ '{print $5"/"$6}' | sort -u)
    [ ${#F[@]} -gt 0 ] || { echo "no failed builds in /var/tmp/portage"; exit 0; }
    for p in "${F[@]}"; do echo "$p   (log: /var/tmp/portage/$p/temp/build.log)"; done
    echo "Check a log first if unsure: a non-LTO failure (fetch, a real bug) won't be fixed by this."
    read -rp "Mark these no-lto (gentoo/etc/portage/package.env/no-lto) and rebuild them? [y/N] " a; [ "$a" = y ] || exit 0
    for p in "${F[@]}"; do echo "$(qatom -F '%{CATEGORY}/%{PN}' "$p") no-lto.conf"; done | tee -a "$P/package.env/no-lto"
    "$S/02-portage.sh" apply || exit 1
    sudo rm -rf $(for p in "${F[@]}"; do echo "/var/tmp/portage/$p"; done)
    long emerge -av1 --keep-going $(for p in "${F[@]}"; do echo "=$p"; done)
    echo "Commit it: git -C ~/git/dots commit -m 'gentoo: no-lto ...' gentoo/etc/portage/package.env/no-lto"
    ;;

*) sed -n '2,15p' "$0" ;;
esac
