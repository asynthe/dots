#!/usr/bin/env bash
# setup.md §17 + "Later": ~amd64, then Graphite / LTO / PGO. Two big compiles.
#
#   ./04-amd64.sh prep     tmux, build-in-RAM (tmpfs) -- then go to tty2 (CTRL+ALT+F2), log in,
#                          `tmux new -s world`, and run the stages there: a terminal inside
#                          Hyprland dies with the session, tty2 + tmux doesn't.
#   ./04-amd64.sh stage1   ~amd64 + gcc graphite/lto/pgo + USE="lto pgo" + every remaining
#                          packages.md block, one world update. Many hours. Then reboot.
#   ./04-amd64.sh stage2   -flto=auto -fno-semantic-interposition, no binhost, emerge -e @world.
#                          Run only after stage1 + a reboot came up clean. Many hours again.
#   ./04-amd64.sh resume   continue an interrupted emerge (portage's saved queue), same inhibit + log.
#   ./04-amd64.sh hyprglass  rebuild the hyprglass plugin (after any Hyprland update).
#   ./04-amd64.sh games    after stage1 + reboot: the games block (interactive: Steam autounmask).
#   ./04-amd64.sh failed   after stage2: packages that failed -> rebuild them without LTO.
#
# Watch from Hyprland: `tmux attach -t world` in any terminal (CTRL+B D detaches).
set -uo pipefail
[ "$(id -u)" -ne 0 ] || { echo "run as meow, not root"; exit 1; }
MD=~/git/dots/gentoo/packages.md
MC=/etc/portage/make.conf
step() { printf '\n\033[1;34m== %s\033[0m\n' "$*"; }
need_tmux() { [ -n "${TMUX:-}" ] || { echo "run this inside tmux on tty2 (see the header)"; exit 1; }; }

# sudo once, kept alive for the whole run (the emerges outlast sudo's 5 min).
sudo -v || exit 1
( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done ) &

block() {   # $1 section, $2 before|emerge  (same parser as 03-packages.sh)
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
atoms() { block "$1" emerge | awk '/^  [a-z0-9-]+\//{print $1}'; }

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
    # tmux copies the pane to the log; piping emerge itself would buffer its Yes/No prompt.
    # No -o: it toggles, so a pipe left open by an earlier run would be switched off.
    [ -n "${TMUX:-}" ] && tmux pipe-pane "cat >> '$LOG'" 2>/dev/null
    echo "+ $*"
    sudo systemd-inhibit --what=sleep:idle:handle-lid-switch --who=p1-rebuild \
        --why="emerge running (04-amd64.sh)" env "$@"
}

snapshot() {   # read-only btrfs snapshot of / (subvol @) before a big rebuild
    # Once per stage: a rerun must not replace the real "before" state.
    ls -d /.snapshots/@-$1-* >/dev/null 2>&1 && { echo "snapshot: kept $(ls -d /.snapshots/@-$1-* | head -1)"; return; }
    local n="/.snapshots/@-$1-$(date +%F-%H%M)"
    sudo btrfs subvolume snapshot -r / "$n" && echo "snapshot: $n"
}

case "${1:-}" in
prep)
    step "tmux (binhost, 1 min)"
    sudo emerge -av --noreplace app-misc/tmux

    step "build in RAM: /var/tmp/portage on tmpfs (24G), big packages build on disk"
    # 24G cap of 30G RAM: tmpfs only uses what builds actually hold; zram (15G) covers peaks.
    sudo mkdir -p /var/tmp/portage /var/tmp/notmpfs
    sudo chown portage:portage /var/tmp/notmpfs
    grep -q ' /var/tmp/portage ' /etc/fstab || echo 'tmpfs  /var/tmp/portage  tmpfs  size=24G,uid=portage,gid=portage,mode=775,noatime  0 0' | sudo tee -a /etc/fstab
    sudo systemctl daemon-reload
    findmnt /var/tmp/portage >/dev/null || sudo mount /var/tmp/portage
    sudo mkdir -p /etc/portage/env /etc/portage/package.env
    echo 'PORTAGE_TMPDIR="/var/tmp/notmpfs"' | sudo tee /etc/portage/env/notmpfs.conf
    # Builds that need more than ~16G of build dir (or RAM + build dir together).
    sudo tee /etc/portage/package.env/notmpfs >/dev/null <<'EOF'
sys-devel/gcc              notmpfs.conf
llvm-core/llvm             notmpfs.conf
llvm-core/clang            notmpfs.conf
dev-lang/rust              notmpfs.conf
net-libs/webkit-gtk        notmpfs.conf
dev-qt/qtwebengine         notmpfs.conf
sys-kernel/gentoo-kernel   notmpfs.conf
games-emulation/rpcs3      notmpfs.conf
app-emulation/wine-staging notmpfs.conf
dev-lang/mono              notmpfs.conf
net-libs/nodejs            notmpfs.conf
dev-db/duckdb              notmpfs.conf
EOF
    findmnt /var/tmp/portage

    # No FEATURES=buildpkg: with binpkg-request-signature, portage rejects its own unsigned
    # binpkgs and every build fails at install. Rollback is the btrfs snapshot instead.

    echo; echo "Now: CTRL+ALT+F2, log in as meow, 'tmux new -s world', '~/git/dots/gentoo/scripts/04-amd64.sh stage1'"
    ;;

stage1)
    need_tmux
    findmnt /var/tmp/portage >/dev/null || { echo "run './04-amd64.sh prep' first"; exit 1; }
    step "news (skim; q to quit)"
    eselect news read new | less
    snapshot pre-amd64

    step "make.conf: ~amd64, USE lto pgo"
    sudo cp -n $MC $MC.stable.bak
    grep -q '^ACCEPT_KEYWORDS=' $MC || echo 'ACCEPT_KEYWORDS="~amd64"' | sudo tee -a $MC
    grep -qE '^USE=.* lto pgo' $MC || sudo sed -i -E 's/^(USE=".*)"$/\1 lto pgo"/' $MC
    grep -E '^(ACCEPT_KEYWORDS|USE)=' $MC

    step "gcc: graphite lto pgo; source firefox out of @world"
    grep -q '^sys-devel/gcc' /etc/portage/package.use/p1 ||
        echo 'sys-devel/gcc graphite lto pgo' | sudo tee -a /etc/portage/package.use/p1
    sudo emerge --deselect www-client/firefox

    step "before blocks of the remaining packages.md blocks"
    BLOCKS=(cli dev virt apps)
    read -rp "Include 'pentest (optional)' too? [y/N] " a; [ "$a" = y ] && BLOCKS+=("pentest (optional)")
    for b in "${BLOCKS[@]}"; do
        bf=$(block "$b" before); [ -n "$bf" ] && { echo "-- $b"; bash -ec "$bf"; }
    done

    NONGAMES=(); for b in "${BLOCKS[@]}"; do mapfile -t -O ${#NONGAMES[@]} NONGAMES < <(atoms "$b"); done

    step "world update on ~amd64 + ${#NONGAMES[@]} new packages (the long one; games come later)"
    echo "If it stops on USE/keyword changes: rerun with --autounmask-write, then 'sudo dispatch-conf', then rerun."
    echo "After your 'Yes' it runs unattended. Sleep, idle and the lid switch are blocked meanwhile."
    # No binhost: its stable binaries next to ~amd64 ebuilds cause the slot conflicts.
    long emerge -avuDN --backtrack=50 --keep-going --getbinpkg=n --usepkg=n @world "${NONGAMES[@]}"

    hyprglass
    # No depclean yet: it removes the old kernel, the fallback if the new one doesn't boot.
    echo; echo "Reboot. Check: uname -r (7.2.x), lsmod | grep nvidia, hyprctl plugin list, systemctl --failed"
    echo "All good? Then: ./04-amd64.sh games, sudo emerge -a --depclean, and stage2."
    ;;

resume)
    need_tmux
    long emerge --resume --keep-going
    ;;

hyprglass) hyprglass ;;

games)
    # Separate, interactive: Steam's 32-bit deps need autounmask + dispatch-conf, and the
    # gpm <-> ncurses loop needs the -gpm rebuild first (packages.md, games).
    need_tmux
    grep -q '^ACCEPT_KEYWORDS=' $MC || { echo "stage1 first"; exit 1; }
    bf=$(block games before); bash -ec "$bf"
    mapfile -t GAMES < <(atoms games)
    step "games (${#GAMES[@]} packages)"
    long USE=-gpm emerge -av1 sys-libs/ncurses
    long emerge -av --getbinpkg=n --usepkg=n --noreplace --backtrack=50 --keep-going --autounmask-write "${GAMES[@]}" ||
        { sudo dispatch-conf; long emerge -av --getbinpkg=n --usepkg=n --noreplace --backtrack=50 --keep-going "${GAMES[@]}"; }
    step "world again (puts gpm back)"
    long emerge -avuDN --getbinpkg=n --usepkg=n --backtrack=50 --keep-going @world
    ;;

stage2)
    need_tmux
    grep -q '^ACCEPT_KEYWORDS=' $MC || { echo "stage1 first"; exit 1; }
    snapshot pre-lto

    # LTO only. Graphite loop flags (-fgraphite-identity -floop-nest-optimize) are left out on
    # purpose: gains are tiny and package-dependent, and they're the likeliest source of silent
    # miscompiles. gcc itself is still built with graphite, so they can be added later.
    # -fno-semantic-interposition: lets gcc inline/optimize calls inside shared libs (python
    # already builds this way); only breaks code that LD_PRELOADs a lib's own internal symbols.
    step "make.conf: -flto=auto -fno-semantic-interposition, binhost off (it ignores your flags)"
    sudo cp -n $MC $MC.prelto.bak
    grep -q -- '-flto' $MC || sudo sed -i -E 's/^(COMMON_FLAGS=".*)"$/\1 -flto=auto -fno-semantic-interposition"/' $MC
    sudo sed -i -E '/^FEATURES=/s/ ?getbinpkg//; /^FEATURES=/s/ ?binpkg-request-signature//' $MC
    grep -E '^(COMMON_FLAGS|FEATURES)=' $MC

    step "no-LTO escape hatch: /etc/portage/env/no-lto.conf (+ package.env/no-lto list)"
    sudo mkdir -p /etc/portage/env /etc/portage/package.env
    sudo tee /etc/portage/env/no-lto.conf >/dev/null <<'EOF'
# For packages that break with LTO/graphite: list them in /etc/portage/package.env/no-lto
COMMON_FLAGS="-march=meteorlake -mabm -mshstk -mno-kl -mno-pconfig -mno-sgx -mno-widekl -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
LDFLAGS="${LDFLAGS} -fno-lto"
EOF
    sudo touch /etc/portage/package.env/no-lto

    step "rebuild everything (-e @world)"
    long emerge -ave --keep-going @world
    echo; echo "Anything that failed: ./04-amd64.sh failed"
    hyprglass
    ;;

failed)
    # A failed build leaves /var/tmp/portage/<cat>/<pkg-ver>/temp/build.log behind; successful
    # ones are cleaned. Those are the failures: retry them without LTO, and remember them.
    mapfile -t F < <(sudo find /var/tmp/portage -mindepth 4 -maxdepth 4 -path '*/temp/build.log' \
        | awk -F/ '{print $5"/"$6}' | sort -u)
    [ ${#F[@]} -gt 0 ] || { echo "no failed builds in /var/tmp/portage"; exit 0; }
    for p in "${F[@]}"; do echo "$p   (log: /var/tmp/portage/$p/temp/build.log)"; done
    echo "Check a log first if unsure: a non-LTO failure (fetch, a real bug) won't be fixed by this."
    read -rp "Mark these no-lto and rebuild them? [y/N] " a; [ "$a" = y ] || exit 0
    for p in "${F[@]}"; do echo "$(qatom -F '%{CATEGORY}/%{PN}' "$p") no-lto.conf"; done \
        | sudo tee -a /etc/portage/package.env/no-lto
    sudo rm -rf $(for p in "${F[@]}"; do echo "/var/tmp/portage/$p"; done)
    sudo emerge -av1 --keep-going $(for p in "${F[@]}"; do echo "=$p"; done)
    ;;

*) sed -n '2,17p' "$0" ;;
esac
