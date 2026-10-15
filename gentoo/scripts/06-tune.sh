#!/usr/bin/env bash
# After stage1 + the reboot into 7.2: desktop tuning. Each step shows itself and asks.
#   ./06-tune.sh             all steps, in order
#   ./06-tune.sh scx boot    only some (names: makeconf scx power mold cache boot)
# scx, mold and cache run emerge: not while 04-amd64.sh is building.
set -uo pipefail
[ "$(id -u)" -ne 0 ] || { echo "run as meow, not root"; exit 1; }
step() { printf '\n\033[1;34m== %s\033[0m\n' "$*"; }
ask()  { read -rp "$1 [y/N] " a; [ "$a" = y ]; }
sudo -v || exit 1
pgrep -x emerge >/dev/null && echo "!! emerge is running: scx, mold and cache would wait on (or race) it"

MC=/etc/portage/make.conf
setvar() {   # $1 name, $2 value: replace the line if present, else append (make.conf only)
    if grep -q "^$1=" $MC; then sudo sed -i "s|^$1=.*|$1=\"$2\"|" $MC
    else echo "$1=\"$2\"" | sudo tee -a $MC >/dev/null; fi
    grep "^$1=" $MC
}

makeconf() {
    # Global settings live in make.conf; package.env is only for per-package exceptions
    # (no-lto, mold, ccache). CFLAGS/LTO are stage2's (04-amd64.sh), not here.
    step "make.conf: Go x86-64-v3, builds at idle CPU/IO priority, parallel install"
    pgrep -x emerge >/dev/null && { echo "!! emerge running: it keeps its old make.conf, do this after"; return 1; }
    ask "Add GOAMD64, PORTAGE_SCHEDULING_POLICY/IONICE, FEATURES parallel-install?" || return 0
    sudo cp -n $MC $MC.pretune.bak
    setvar GOAMD64 v3                                  # Go's -march: Meteor Lake has AVX2/BMI/FMA
    setvar PORTAGE_SCHEDULING_POLICY idle              # builds only get CPU nothing else wants
    setvar PORTAGE_IONICE_COMMAND 'ionice -c 3 -p \${PID}'   # same for disk
    grep -q '^FEATURES=.*parallel-install' $MC ||
        sudo sed -i -E 's/^(FEATURES=".*)"$/\1 parallel-install"/' $MC
    grep '^FEATURES=' $MC
    echo "Builds now yield to the desktop (and to games: a build may crawl while you play)."
}

scx() {
    step "sched-ext: scx_lavd via scx_loader (falls back to the normal scheduler on any error)"
    [ "$(cat /sys/kernel/sched_ext/state 2>/dev/null)" ] || { echo "!! kernel has no sched_ext (boot 7.2 first)"; return 1; }
    ask "Install sys-kernel/scx, default scx_lavd (Auto), enable scx_loader?" || return 0
    sudo emerge -av --noreplace sys-kernel/scx || return 1
    local c=/etc/scx_loader/config.toml
    [ -f $c ] || { echo "!! $c missing: check the scx-loader install"; return 1; }
    sudo cp -n $c $c.orig
    # Set the two keys whether the shipped file has them (commented or not) or not.
    for kv in 'default_sched = "scx_lavd"' 'default_mode = "Auto"'; do
        k=${kv%% *}
        if grep -qE "^#? *$k *=" $c; then sudo sed -i -E "s|^#? *$k *=.*|$kv|" $c
        else echo "$kv" | sudo tee -a $c >/dev/null; fi
    done
    grep -E '^default_(sched|mode)' $c
    echo "(compare with the comments in $c.orig if scx_loader rejects it)"
    sudo systemctl enable --now scx_loader
    sleep 2
    echo "state: $(cat /sys/kernel/sched_ext/state)   ops: $(cat /sys/kernel/sched_ext/root/ops 2>/dev/null)"
    echo "Watch it: scxtop. Off: sudo systemctl disable --now scx_loader. Other: default_sched = \"scx_bpfland\"."
}

power() {
    # ThinkPad DYTC: the firmware does thermals, power-profiles-daemon drives it (platform_profile).
    # thermald sees dytc_lapmode and exits ("can't run on this platform"), so it's dead weight here.
    step "power: power-profiles-daemon only (thermald exits on ThinkPad DYTC), no competing daemons"
    systemctl is-active power-profiles-daemon
    for p in sys-power/tlp sys-power/tuned sys-power/auto-cpufreq; do
        [ -n "$(qlist -IC "$p")" ] && echo "!! $p installed: conflicts with power-profiles-daemon"
    done
    powerprofilesctl list
    echo "Switch: powerprofilesctl set performance|balanced|power-saver"
    ask "Disable thermald and remove it from @world?" || return 0
    sudo systemctl disable thermald
    sudo emerge --deselect sys-power/thermald && echo "next depclean removes it"
}

cache() {
    # Not for portage globally: a cache only hits on the same source + same flags. ~amd64 bumps
    # versions, stage2 changes every flag, so world updates would miss and just fill the disk.
    step "compile caches for your own code: ccache (C/C++) + sccache (Rust); portage opt-in per package"
    ask "Install ccache + sccache, cargo uses sccache, ccache.conf for portage?" || return 0
    sudo emerge -av --noreplace dev-util/ccache dev-util/sccache || return 1
    mkdir -p ~/.cargo
    if grep -q 'rustc-wrapper' ~/.cargo/config.toml 2>/dev/null; then
        echo "~/.cargo/config.toml already sets rustc-wrapper:"; grep rustc-wrapper ~/.cargo/config.toml
    else
        printf '[build]\nrustc-wrapper = "sccache"\n' >> ~/.cargo/config.toml
    fi
    ccache --max-size=20G >/dev/null
    echo "C/C++: CC='ccache gcc' CXX='ccache g++', or cmake -DCMAKE_C_COMPILER_LAUNCHER=ccache"
    # Portage: for a big package you rebuild at the same version (USE tweaks, retries after a fail).
    sudo mkdir -p /etc/portage/env /etc/portage/package.env /var/cache/ccache
    sudo chown portage:portage /var/cache/ccache && sudo chmod 2775 /var/cache/ccache
    printf 'FEATURES="ccache"\nCCACHE_DIR="/var/cache/ccache"\n' | sudo tee /etc/portage/env/ccache.conf
    sudo touch /etc/portage/package.env/ccache
    echo "Use it for a package: echo 'cat/pkg ccache.conf' | sudo tee -a /etc/portage/package.env/ccache"
    echo "Stats: ccache -s, sccache --show-stats, sudo CCACHE_DIR=/var/cache/ccache ccache -s"
}

mold() {
    step "mold: fast linker, opt-in per package (not global: untested with stage2's LTO)"
    ask "Install sys-devel/mold and create /etc/portage/env/mold.conf?" || return 0
    sudo emerge -av --noreplace sys-devel/mold || return 1
    sudo mkdir -p /etc/portage/env /etc/portage/package.env
    echo 'LDFLAGS="${LDFLAGS} -fuse-ld=mold"' | sudo tee /etc/portage/env/mold.conf
    sudo touch /etc/portage/package.env/mold
    echo "Use it for a package: echo 'cat/pkg mold.conf' | sudo tee -a /etc/portage/package.env/mold"
    echo "Own projects: mold -run make / cargo build (or -fuse-ld=mold)."
}

boot() {
    step "boot time (read-only)"
    systemd-analyze
    echo; systemd-analyze blame | head -15
    echo; systemd-analyze critical-chain | head -20
    echo; systemctl --failed --no-legend
    echo "Send the slow ones to Claude before disabling anything."
}

STEPS=(makeconf scx power mold cache boot)
[ $# -gt 0 ] && STEPS=("$@")
for s in "${STEPS[@]}"; do "$s"; done
