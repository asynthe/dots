#!/usr/bin/env bash
# Gentoo on p1, from the repo's gentoo/ config. Usage and the reasoning behind each step: notes/gentoo.md.
set -uo pipefail

MAKECONF=~/git/dots/gentoo/make.conf
E=/etc/portage
LOGS=~/.local/state/p1-setup/logs
GAMES=(app-emulation/wine-staging app-emulation/winetricks dev-lang/mono games-util/lutris games-util/gamemode app-emulation/protontricks games-util/protonup-rs games-util/steam-launcher games-arcade/osu-lazer games-engines/uzdoom games-emulation/dolphin games-emulation/pcsx2 games-emulation/ppsspp games-emulation/azahar games-emulation/rpcs3 games-emulation/eden)

step() { printf '\n\033[1;34m== %s\033[0m\n' "$*"; }
ask() {
    read -rp "$1 [y/N] " a
    [ "$a" = y ]
}

usage() {
    cat <<'EOF'
gentoo.sh portage [diff|apply|pull]     /etc/portage/make.conf <-> gentoo/make.conf
gentoo.sh build prep|world|resume|failed|games|hyprglass
gentoo.sh system [cmdline lid fw nvidia hw fwupd cleanup ssh]
gentoo.sh tune [scx power mold cache boot]
EOF
}

portage() {
    case "${1:-diff}" in
        diff) diff -u --color=auto "$E/make.conf" "$MAKECONF" && echo "$E/make.conf matches the repo" ;;
        apply)
            portage diff && return 0
            ask "Copy gentoo/make.conf over $E/make.conf?" || return 1
            # Copied as root, never symlinked: portage sources make.conf as root on every emerge.
            sudo install -m644 -o root -g root "$MAKECONF" "$E/make.conf" && echo "applied"
            ;;
        pull)
            diff -u --color=auto "$MAKECONF" "$E/make.conf" && return 0
            ask "Copy $E/make.conf into the repo?" || return 1
            cp "$E/make.conf" "$MAKECONF" && git -C ~/git/dots status --short gentoo
            ;;
        *) usage ;;
    esac
}

portage_applied() {
    portage diff >/dev/null || {
        echo "$E/make.conf differs from the repo: gentoo.sh portage apply"
        exit 1
    }
}

long() {
    mkdir -p "$LOGS"
    touch "$LOG"
    echo "+ $*"
    local pp=()
    command -v powerprofilesctl >/dev/null &&
        pp=(powerprofilesctl launch -p performance -r "emerge (gentoo.sh)" --)
    # No MAKEOPTS here: the environment would beat package.env, so heavy.conf's -j8 stops applying.
    local power=(EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=24 --with-bdeps=y")
    # Own scope with OOMPolicy=continue, or one OOM-killed compiler stops the whole login scope.
    sudo systemd-run --scope --quiet --collect --unit="p1-emerge-$(date +%s)" \
        --property=OOMPolicy=continue \
        systemd-inhibit --what=sleep:idle:handle-lid-switch --who=p1-rebuild \
        --why="emerge running (gentoo.sh)" \
        "${pp[@]}" \
        script -qefa "$LOG" -c "$(printf '%q ' env "${power[@]}" "$@")"
}

snapshot() {
    if ls -d "/.snapshots/@-$1-"* >/dev/null 2>&1; then
        echo "snapshot: kept $(ls -d "/.snapshots/@-$1-"* | head -1)"
        return
    fi
    local n
    n="/.snapshots/@-$1-$(date +%F-%H%M)"
    sudo btrfs subvolume snapshot -r / "$n" && echo "snapshot: $n"
}

hyprglass() {
    step "rebuild hyprglass against the new Hyprland"
    [ -d ~/.cache/hyprglass ] || git clone --branch v0.7.0 --depth 1 https://github.com/hyprnux/hyprglass ~/.cache/hyprglass
    make -C ~/.cache/hyprglass clean
    make -C ~/.cache/hyprglass CXX=g++ INCLUDES="$(pkg-config --cflags hyprland pixman-1 libdrm lua5.4)" &&
        sudo install -Dm755 ~/.cache/hyprglass/hyprglass.so /usr/local/lib/libhyprglass.so
}

build() {
    LOG=$LOGS/$(date +%F-%H%M)-${1:-none}.log
    sudo -v || exit 1
    (while kill -0 $$ 2>/dev/null; do
        sudo -n true
        sleep 50
    done) &
    case "${1:-}" in
        prep)
            step "build in RAM: /var/tmp/portage on tmpfs (24G), big packages build on disk"
            sudo mkdir -p /var/tmp/portage /var/tmp/notmpfs
            sudo chown portage:portage /var/tmp/notmpfs
            grep -q ' /var/tmp/portage ' /etc/fstab ||
                echo 'tmpfs  /var/tmp/portage  tmpfs  size=24G,uid=portage,gid=portage,mode=775,noatime  0 0' | sudo tee -a /etc/fstab
            sudo systemctl daemon-reload
            findmnt /var/tmp/portage >/dev/null || sudo mount /var/tmp/portage
            findmnt /var/tmp/portage
            echo
            echo "Now: CTRL+ALT+F2, log in as meow, tmux new -s world, 'gentoo.sh build world'"
            ;;
        world)
            findmnt /var/tmp/portage >/dev/null || {
                echo "run 'gentoo.sh build prep' first"
                exit 1
            }
            portage_applied
            step "sync: gentoo + the overlays in repos.conf (guru, hyproverlay, steam-overlay)"
            sudo emaint sync -a
            step "news (skim; q to quit)"
            eselect news read new | less
            snapshot pre-world
            step "gcc (graphite lto pgo), then switch to its newest slot"
            long emerge -av1 --keep-going sys-devel/gcc
            sudo gcc-config "$(gcc-config -l | wc -l)" && gcc-config -c
            step "rebuild everything (-e @world): ~amd64 versions, LTO, the profile's flags"
            echo "After your 'Yes' it runs unattended. Sleep, idle and the lid switch are blocked meanwhile."
            long USE=-gpm emerge -ave --keep-going --backtrack=50 @world
            step "gpm back (ncurses, gpm and what links them)"
            long emerge -avuDN --keep-going --backtrack=50 @world
            echo
            echo "Failed ones: gentoo.sh build failed. Then: sudo emerge -av @preserved-rebuild,"
            echo "sudo dispatch-conf (z for files you edited), check sudo -v, reboot into the new kernel."
            ;;
        resume)
            long emerge --resume --keep-going
            ;;
        hyprglass) hyprglass ;;
        games)
            portage_applied
            local games=("${GAMES[@]}") g=(--getbinpkg=n --usepkg=n --noreplace --backtrack=50)
            step "games: autounmask (anything new), then dispatch-conf: u"
            long emerge -a "${g[@]}" --autounmask-only --autounmask-write "${games[@]}" || true
            sudo dispatch-conf
            step "loops: ncurses without gpm (64 + 32-bit), mono minimal"
            long USE=-gpm emerge -av1 sys-libs/ncurses
            [ -n "$(qlist -IC dev-lang/mono)" ] || long USE=minimal emerge -av1 dev-lang/mono
            step "games (${#games[@]} packages)"
            long emerge -av "${g[@]}" --keep-going "${games[@]}"
            step "world again (puts gpm back, full mono)"
            long emerge -avuDN --getbinpkg=n --usepkg=n --backtrack=50 --keep-going @world
            ;;
        failed)
            local failed p a
            mapfile -t failed < <(sudo find /var/tmp/portage -mindepth 4 -maxdepth 4 -path '*/temp/build.log' |
                awk -F/ '{print $5"/"$6}' | sort -u)
            [ ${#failed[@]} -gt 0 ] || {
                echo "no failed builds in /var/tmp/portage"
                exit 0
            }
            for p in "${failed[@]}"; do echo "$p   (log: /var/tmp/portage/$p/temp/build.log)"; done
            echo "Check a log first if unsure: a non-LTO failure (fetch, a real bug) won't be fixed by this."
            read -rp "Mark these no-lto ($E/package.env/no-lto) and rebuild them? [y/N] " a
            [ "$a" = y ] || exit 0
            for p in "${failed[@]}"; do echo "$(qatom -F '%{CATEGORY}/%{PN}' "$p") no-lto.conf"; done |
                sudo tee -a "$E/package.env/no-lto"
            for p in "${failed[@]}"; do sudo rm -rf "/var/tmp/portage/$p"; done
            long emerge -av1 --keep-going "${failed[@]/#/=}"
            ;;
        *) usage ;;
    esac
}

uki_note() {
    if ls -d /var/db/pkg/sys-kernel/gentoo-kernel-7.* >/dev/null 2>&1; then
        echo "!! gentoo-kernel 7.x is already installed: sudo emerge --config sys-kernel/gentoo-kernel"
    else
        echo "The kernel being built picks this up when it installs."
    fi
}

system_cmdline() {
    step "kernel params: i915.enable_psr=0 (PSR blanks the panel), video=DP-1:d (phantom DP-1)"
    echo "now: $(cat /etc/kernel/cmdline)"
    ask "Append them?" || return 0
    local c p
    c=$(cat /etc/kernel/cmdline)
    for p in i915.enable_psr=0 video=DP-1:d; do
        grep -qw -- "$p" <<<"$c" || c="$c $p"
    done
    echo "$c" | sudo tee /etc/kernel/cmdline
    uki_note
}

system_lid() {
    step "lid: suspend on battery and AC, ignore when docked (applies after reboot)"
    ask "Write /etc/systemd/logind.conf.d/lid.conf?" || return 0
    sudo mkdir -p /etc/systemd/logind.conf.d
    printf '[Login]\nHandleLidSwitch=suspend\nHandleLidSwitchExternalPower=suspend\nHandleLidSwitchDocked=ignore\n' |
        sudo tee /etc/systemd/logind.conf.d/lid.conf
}

system_fw() {
    step "firewall: table inet p1, input policy drop (tailscale, libvirt, syncthing, Steam open)"
    ask "Install and start it?" || return 0
    sudo mkdir -p /etc/nftables.d
    sudo tee /etc/nftables.d/p1.nft >/dev/null <<'EOF'
table inet p1 {}
delete table inet p1
table inet p1 {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        ct state invalid drop
        iif lo accept
        iifname { "tailscale0", "virbr0", "virbr1" } accept
        meta l4proto { icmp, ipv6-icmp } accept
        udp dport 41641 accept
        tcp dport 22000 accept
        udp dport { 22000, 21027 } accept
        tcp dport { 27015, 27036, 27040 } accept
        udp dport { 27015, 27031-27036 } accept
    }
}
EOF
    sudo tee /etc/systemd/system/p1-firewall.service >/dev/null <<'EOF'
[Unit]
Description=p1 nftables rules
Before=network-pre.target
Wants=network-pre.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/nft -f /etc/nftables.d/p1.nft
ExecReload=/usr/sbin/nft -f /etc/nftables.d/p1.nft
[Install]
WantedBy=multi-user.target
EOF
    sudo nft -c -f /etc/nftables.d/p1.nft || {
        echo "!! rules don't parse, not loading"
        return 1
    }
    sudo systemctl daemon-reload
    sudo systemctl enable --now p1-firewall
    sudo nft list table inet p1 | head -5
    if ping -c1 -W3 gentoo.org >/dev/null; then
        echo "network still up: OK"
    else
        echo "!! no network: sudo nft delete table inet p1"
    fi
}

system_nvidia() {
    step "nvidia dGPU power management (powers off when idle; driver handles suspend)"
    ask "Write /etc/modprobe.d/nvidia-pm.conf and enable nvidia-powerd?" || return 0
    echo 'options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1' |
        sudo tee /etc/modprobe.d/nvidia-pm.conf
    sudo systemctl enable nvidia-powerd
    uki_note
    echo "After the reboot: grep -E 'DynamicPower|PreserveVideo|SuspendNotif' /proc/driver/nvidia/params   # 2 / 1 / 1"
}

system_hw() {
    step "keyd (HHKB, Copilot key), colord, bluetooth on at boot, groups, nvidia-offload"
    ask "Do all of these?" || return 0
    sudo mkdir -p /etc/keyd
    printf '[ids]\n04fe:0021\n\n[main]\nmuhenkan = leftmeta\nhenkan = rightmeta\n' | sudo tee /etc/keyd/hhkb.conf
    printf '[ids]\n*\n\n[main]\nf23 = command(%s)\n' "$HOME/git/dots/scripts/hypr/key-copilot-hermes.sh" |
        sudo tee /etc/keyd/default.conf
    sudo systemctl enable --now keyd colord bluetooth
    sudo sed -i 's/^#AutoEnable=true$/AutoEnable=true/' /etc/bluetooth/main.conf
    grep -n '^AutoEnable' /etc/bluetooth/main.conf
    sudo usermod -aG tss,kvm meow && echo "groups tss,kvm: from your next login"
    [ -e /usr/local/bin/nvidia-offload ] || sudo ln -s /usr/bin/prime-run /usr/local/bin/nvidia-offload
    ls -la /usr/local/bin/nvidia-offload
}

system_fwupd() {
    step "fwupd: ESP at /efi, no shim (fwupdx64.efi is signed with your sbctl key)"
    if sudo grep -q '^\[uefi_capsule\]' /etc/fwupd/fwupd.conf; then
        echo "fwupd.conf already has [uefi_capsule]:"
        sudo sed -n '/^\[uefi_capsule\]/,/^\[/p' /etc/fwupd/fwupd.conf
        return 0
    fi
    ask "Append [uefi_capsule] to /etc/fwupd/fwupd.conf?" || return 0
    printf '\n[uefi_capsule]\nEspLocation=/efi\nDisableShimForSecureBoot=true\n' | sudo tee -a /etc/fwupd/fwupd.conf
    sudo systemctl restart fwupd
    sbverify --list /usr/libexec/fwupd/efi/fwupdx64.efi.signed 2>&1 | grep -i 'issuer'
    echo "Firmware updates only on AC: sudo fwupdmgr refresh && sudo fwupdmgr get-updates"
}

system_cleanup() {
    step "cleanup: stage3's baseline binhost file, systemd-networkd (iwd does Wi-Fi)"
    ask "Remove binrepos.conf/gentoo.conf and disable networkd?" || return 0
    sudo rm -f /etc/portage/binrepos.conf/gentoo.conf
    ls /etc/portage/binrepos.conf/
    sudo systemctl disable --now systemd-networkd.service systemd-networkd.socket \
        systemd-networkd-wait-online.service systemd-networkd-varlink.socket \
        systemd-networkd-varlink-metrics.socket systemd-networkd-resolve-hook.socket
    ping -c1 -W3 gentoo.org >/dev/null && echo "network still up: OK" || echo "!! no network"
}

system_ssh() {
    step "ssh: ~/git/auth/ssh/p1 for every outbound ssh, inbound keys only, sshd (port 22 only via tailscale0)"
    [ -f ~/git/auth/ssh/p1 ] || {
        echo "!! ~/git/auth/ssh/p1 missing"
        return 1
    }
    ask "Write ~/.ssh/config + authorized_keys, sshd p1.conf, enable sshd?" || return 0
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    [ -f ~/.ssh/config ] && cp ~/.ssh/config ~/.ssh/config.bak
    cat >~/.ssh/config <<'EOF'
Host sarten
    HostName 192.168.1.135
    User asynthe

Host *
    IdentityFile ~/git/auth/ssh/p1
    IdentitiesOnly yes
    KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,curve25519-sha256
EOF
    chmod 600 ~/.ssh/config
    cat >~/.ssh/authorized_keys <<'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDnUPjUAi2Red+yEOocv3LorVYbA3VHTI6z4QjGX+9T s24
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRuhUZDJsm4KiLYGqo5g2Usd3fvW5Tu+sCr5O5CRaQ8 macbook
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0H7gtdrNpsghM6LQ3jPDoeDkJMQW4/YDfc+DzMF1/j p1
EOF
    chmod 600 ~/.ssh/authorized_keys
    printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' |
        sudo tee /etc/ssh/sshd_config.d/p1.conf
    sudo sshd -t && sudo systemctl enable --now sshd || echo "!! sshd config test failed, not started"
    sudo nft list table inet p1 >/dev/null 2>&1 || echo "!! no p1 firewall yet: port 22 is open on Wi-Fi"

    git config --global user.name asynthe
    git config --global init.defaultBranch main
    read -rp "git email (empty = skip): " e
    [ -n "$e" ] && git config --global user.email "$e"
    git config --global -l
    if ask "Test GitHub, GitLab, sarten now? (first time asks to trust each host key)"; then
        ssh -T git@github.com
        ssh -T git@gitlab.com
        ssh sarten true && echo "sarten: OK"
    fi
}

system() {
    sudo -v || exit 1
    local steps=(cmdline lid fw nvidia hw fwupd cleanup ssh) s
    [ $# -gt 0 ] && steps=("$@")
    for s in "${steps[@]}"; do "system_$s"; done
}

tune_scx() {
    step "sched-ext: scx_lavd via scx_loader (falls back to the normal scheduler on any error)"
    [ "$(cat /sys/kernel/sched_ext/state 2>/dev/null)" ] || {
        echo "!! kernel has no sched_ext"
        return 1
    }
    ask "Install sys-kernel/scx, default scx_lavd (Auto), enable scx_loader?" || return 0
    sudo emerge -av --noreplace sys-kernel/scx || return 1
    local c=/etc/scx_loader/config.toml kv k
    [ -f $c ] || {
        echo "!! $c missing: check the scx-loader install"
        return 1
    }
    sudo cp -n $c $c.orig
    for kv in 'default_sched = "scx_lavd"' 'default_mode = "Auto"'; do
        k=${kv%% *}
        if grep -qE "^#? *$k *=" $c; then
            sudo sed -i -E "s|^#? *$k *=.*|$kv|" $c
        else
            echo "$kv" | sudo tee -a $c >/dev/null
        fi
    done
    grep -E '^default_(sched|mode)' $c
    sudo systemctl enable --now scx_loader
    sleep 2
    echo "state: $(cat /sys/kernel/sched_ext/state)   ops: $(cat /sys/kernel/sched_ext/root/ops 2>/dev/null)"
}

tune_power() {
    step "power: power-profiles-daemon only (thermald exits on ThinkPad DYTC)"
    systemctl is-active power-profiles-daemon
    local p
    for p in sys-power/tlp sys-power/tuned sys-power/auto-cpufreq; do
        [ -n "$(qlist -IC "$p")" ] && echo "!! $p installed: conflicts with power-profiles-daemon"
    done
    powerprofilesctl list
    ask "Disable thermald and remove it from @world?" || return 0
    sudo systemctl disable thermald
    sudo emerge --deselect sys-power/thermald && echo "next depclean removes it"
}

tune_cache() {
    step "compile caches for your own code: ccache (C/C++) + sccache (Rust); portage opt-in per package"
    ask "Install ccache + sccache, cargo uses sccache, ccache.conf for portage?" || return 0
    sudo emerge -av --noreplace dev-util/ccache dev-util/sccache || return 1
    mkdir -p ~/.cargo
    grep -q 'rustc-wrapper' ~/.cargo/config.toml 2>/dev/null ||
        printf '[build]\nrustc-wrapper = "sccache"\n' >>~/.cargo/config.toml
    ccache --max-size=20G >/dev/null
    sudo mkdir -p /var/cache/ccache
    sudo chown portage:portage /var/cache/ccache && sudo chmod 2775 /var/cache/ccache
    echo "Per package: 'cat/pkg ccache.conf' in $E/package.env/ccache (env/ccache.conf: FEATURES=ccache)"
}

tune_mold() {
    step "mold: fast linker, opt-in per package"
    ask "Install sys-devel/mold?" || return 0
    sudo emerge -av --noreplace sys-devel/mold || return 1
    echo "Per package: 'cat/pkg mold.conf' in $E/package.env/mold (env/mold.conf: -fuse-ld=mold)"
}

tune_boot() {
    step "boot time (read-only)"
    systemd-analyze
    echo
    systemd-analyze blame | head -15
    echo
    systemd-analyze critical-chain | head -20
    echo
    systemctl --failed --no-legend
}

tune() {
    sudo -v || exit 1
    pgrep -x emerge >/dev/null && echo "!! emerge is running: scx, mold and cache would wait on it"
    local steps=(scx power mold cache boot) s
    [ $# -gt 0 ] && steps=("$@")
    for s in "${steps[@]}"; do "tune_$s"; done
}

main() {
    [ "$(id -u)" -ne 0 ] || {
        echo "run as meow, not root"
        exit 1
    }
    local cmd=${1:-help}
    shift || true
    case $cmd in
        portage | build | system | tune) "$cmd" "$@" ;;
        *) usage ;;
    esac
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
