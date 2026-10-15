#!/usr/bin/env bash
# setup.md §4 (kernel params, lid, firewall), §6 (hardware, nvidia, fwupd), cleanup, §2 ssh.
# Safe during the stage1 build: nothing here runs emerge. Each step shows itself and asks.
# Fingerprint (§6) is not here: PAM edits are done by hand, with a root shell open on tty2.
#   ./05-system.sh            all steps, in order
#   ./05-system.sh fw ssh     only some (names: cmdline lid fw nvidia hw fwupd cleanup ssh)
set -uo pipefail
[ "$(id -u)" -ne 0 ] || { echo "run as meow, not root"; exit 1; }
step() { printf '\n\033[1;34m== %s\033[0m\n' "$*"; }
ask()  { read -rp "$1 [y/N] " a; [ "$a" = y ]; }
sudo -v || exit 1

kernel_built() { ls -d /var/db/pkg/sys-kernel/gentoo-kernel-7.* >/dev/null 2>&1; }
uki_note() {
    if kernel_built; then
        echo "!! gentoo-kernel 7.x is already installed: after the build, run"
        echo "   sudo emerge --config sys-kernel/gentoo-kernel   (new UKI with this change)"
    else
        echo "The 7.2 kernel being built tonight picks this up when it installs."
    fi
}

cmdline() {
    step "§4 kernel params: i915.enable_psr=0 (PSR blanks the panel), video=DP-1:d (phantom DP-1)"
    echo "now: $(cat /etc/kernel/cmdline)"
    ask "Append them?" || return 0
    local c; c=$(cat /etc/kernel/cmdline)
    for p in i915.enable_psr=0 video=DP-1:d; do
        grep -qw -- "$p" <<<"$c" || c="$c $p"
    done
    echo "$c" | sudo tee /etc/kernel/cmdline
    uki_note
}

lid() {
    step "§4 lid: suspend on battery and AC, ignore when docked (applies after reboot)"
    ask "Write /etc/systemd/logind.conf.d/lid.conf?" || return 0
    sudo mkdir -p /etc/systemd/logind.conf.d
    printf '[Login]\nHandleLidSwitch=suspend\nHandleLidSwitchExternalPower=suspend\nHandleLidSwitchDocked=ignore\n' \
        | sudo tee /etc/systemd/logind.conf.d/lid.conf
    # No logind restart: on a live session that can kill it. The reboot loads it.
}

fw() {
    step "§4 firewall: table inet p1, input policy drop (tailscale, libvirt, syncthing, Steam open)"
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
    sudo nft -c -f /etc/nftables.d/p1.nft || { echo "!! rules don't parse, not loading"; return 1; }
    sudo systemctl daemon-reload
    sudo systemctl enable --now p1-firewall
    sudo nft list table inet p1 | head -5
    ping -c1 -W3 gentoo.org >/dev/null && echo "network still up: OK" ||
        { echo "!! no network: sudo nft delete table inet p1  (and tell Claude)"; }
}

nvidia() {
    step "§6 nvidia dGPU power management (powers off when idle; driver handles suspend)"
    ask "Write /etc/modprobe.d/nvidia-pm.conf and enable nvidia-powerd?" || return 0
    echo 'options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1' \
        | sudo tee /etc/modprobe.d/nvidia-pm.conf
    sudo systemctl enable nvidia-powerd
    uki_note
    echo "After the reboot: grep -E 'DynamicPower|PreserveVideo|SuspendNotif' /proc/driver/nvidia/params   # 2 / 1 / 1"
}

hw() {
    step "§6 HHKB (keyd: Muhenkan/Henkan -> meta), colord, bluetooth on at boot, groups, nvidia-offload"
    ask "Do all of these?" || return 0
    printf '[ids]\n04fe:0021\n\n[main]\nmuhenkan = leftmeta\nhenkan = rightmeta\n' | sudo tee /etc/keyd/hhkb.conf
    sudo systemctl enable --now keyd colord bluetooth
    sudo sed -i 's/^#AutoEnable=true$/AutoEnable=true/' /etc/bluetooth/main.conf
    grep -n '^AutoEnable' /etc/bluetooth/main.conf
    sudo usermod -aG tss,kvm meow && echo "groups tss,kvm: from your next login"
    [ -e /usr/local/bin/nvidia-offload ] || sudo ln -s /usr/bin/prime-run /usr/local/bin/nvidia-offload
    ls -la /usr/local/bin/nvidia-offload
}

fwupd() {
    step "§6 fwupd: ESP at /efi, no shim (fwupdx64.efi is signed with your sbctl key)"
    if sudo grep -q '^\[uefi_capsule\]' /etc/fwupd/fwupd.conf; then
        echo "fwupd.conf already has [uefi_capsule]:"; sudo sed -n '/^\[uefi_capsule\]/,/^\[/p' /etc/fwupd/fwupd.conf
        echo "Edit by hand if needed: sudoedit /etc/fwupd/fwupd.conf"; return 0
    fi
    ask "Append [uefi_capsule] to /etc/fwupd/fwupd.conf?" || return 0
    printf '\n[uefi_capsule]\nEspLocation=/efi\nDisableShimForSecureBoot=true\n' | sudo tee -a /etc/fwupd/fwupd.conf
    sudo systemctl restart fwupd
    sbverify --list /usr/libexec/fwupd/efi/fwupdx64.efi.signed 2>&1 | grep -i 'issuer' # CN=Database Key
    echo "Firmware updates: sudo fwupdmgr refresh && sudo fwupdmgr get-updates  (update only on AC;"
    echo "a BIOS/dbx update changes PCR7: passphrase once, then re-enroll, install.md step 18)"
}

cleanup() {
    step "cleanup: stage3's baseline binhost file, systemd-networkd (manages nothing; iwd does Wi-Fi)"
    ask "Remove binrepos.conf/gentoo.conf and disable networkd?" || return 0
    sudo rm -f /etc/portage/binrepos.conf/gentoo.conf
    ls /etc/portage/binrepos.conf/
    sudo systemctl disable --now systemd-networkd.service systemd-networkd.socket \
        systemd-networkd-wait-online.service systemd-networkd-varlink.socket \
        systemd-networkd-varlink-metrics.socket systemd-networkd-resolve-hook.socket
    ping -c1 -W3 gentoo.org >/dev/null && echo "network still up: OK" || echo "!! no network (tell Claude)"
}

ssh() {
    step "§2 ssh: ~/git/auth/ssh/p1 for every outbound ssh, inbound keys only, sshd (port 22 only via tailscale0)"
    [ -f ~/git/auth/ssh/p1 ] || { echo "!! ~/git/auth/ssh/p1 missing"; return 1; }
    ask "Write ~/.ssh/config + authorized_keys, sshd p1.conf, enable sshd?" || return 0
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    [ -f ~/.ssh/config ] && cp ~/.ssh/config ~/.ssh/config.bak
    cat > ~/.ssh/config <<'EOF'
Host sarten
    HostName 192.168.1.135
    User asynthe

Host *
    IdentityFile ~/git/auth/ssh/p1
    IdentitiesOnly yes
    KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,curve25519-sha256
EOF
    chmod 600 ~/.ssh/config
    cat > ~/.ssh/authorized_keys <<'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDnUPjUAi2Red+yEOocv3LorVYbA3VHTI6z4QjGX+9T s24
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRuhUZDJsm4KiLYGqo5g2Usd3fvW5Tu+sCr5O5CRaQ8 macbook
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0H7gtdrNpsghM6LQ3jPDoeDkJMQW4/YDfc+DzMF1/j p1
EOF
    chmod 600 ~/.ssh/authorized_keys
    printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' \
        | sudo tee /etc/ssh/sshd_config.d/p1.conf
    sudo sshd -t && sudo systemctl enable --now sshd || echo "!! sshd config test failed, not started"
    # Without the firewall (fw step), sshd listens on every interface.
    sudo nft list table inet p1 >/dev/null 2>&1 || echo "!! no p1 firewall yet: port 22 is open on Wi-Fi"

    git config --global user.name asynthe
    git config --global init.defaultBranch main
    read -rp "git email (config/jj says \"ben\", not an address; empty = skip): " e
    [ -n "$e" ] && git config --global user.email "$e"
    git config --global -l

    if ask "Test GitHub, GitLab, sarten now? (first time asks to trust each host key)"; then
        command ssh -T git@github.com; command ssh -T git@gitlab.com; command ssh sarten true && echo "sarten: OK"
    fi
}

STEPS=(cmdline lid fw nvidia hw fwupd cleanup ssh)
[ $# -gt 0 ] && STEPS=("$@")
for s in "${STEPS[@]}"; do "$s"; done
echo; echo "Done. Reboot comes after the build (04-amd64.sh stage1)."
