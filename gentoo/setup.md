# Gentoo on p1: setup

After `install.md`: from a tty to the full NixOS-equivalent desktop. Packages live in
`packages.md`; each section names the block to paste. The source of truth is `~/git/dots/nix`
(the NixOS flake, commit ee0d0bf); each section names the aspects it replaces, so "is X done?" is
a search for the aspect name.

Scripts in `scripts/` run the long or repetitive parts; each step shows itself and asks first.
They need the dots clone (§0), and they run as meow, not root.

| Script | Does |
|---|---|
| `03-packages.sh [block …]` | `packages.md` blocks, read straight from that file |
| `05-system.sh [step …]` | §4 kernel params, lid, firewall; §6 hardware, nvidia, fwupd; §2 ssh |
| `04-amd64.sh <stage>` | §17: `~amd64`, LTO/PGO, the big rebuilds |
| `06-tune.sh [step …]` | §18: make.conf, sched-ext, power, mold, compile caches |

## Rules

Same as `install.md`, plus:

1. A new package goes in `packages.md` first, then gets emerged from there.
2. Read the `-a` list before saying yes. Everything runs on **stable** (binhost, fast) until §17
   switches to `~amd64`.
3. Nothing that only existed because of Nix comes over (§15).

Carried over from the first install: BIOS 1.21 and the 2023 UEFI CA (still flashed), SSH keys
on github/gitlab/sarten (in `~/git/auth`).

---

## 0. Hyprland + kitty, first

From the tty, typed by hand. After this everything is copy-paste from a terminal.

```bash
sudo eselect repository enable hyproverlay && sudo emaint sync -r hyproverlay
echo '*/*::hyproverlay ~amd64' | sudo tee /etc/portage/package.accept_keywords/hyproverlay
sudo emerge -av gui-wm/hyprland x11-terms/kitty media-fonts/dejavu
start-hyprland
```

**SUPER+Q** opens kitty, **SUPER+M** exits. kitty copies with **CTRL+SHIFT+C** and pastes with
**CTRL+SHIFT+V**. Read the guide with `less ~/gentoo/setup.md` (in nvim the mouse selects inside
nvim, not kitty) and paste from here on.

The dots (public, https needs no key):

```bash
mkdir -p ~/git && git clone https://gitlab.com/asynthe/dots.git ~/git/dots
rm -r ~/gentoo
```

The guides are now in `~/git/dots/gentoo/`. Wallpapers are git-lfs: `git -C ~/git/dots lfs pull`
once git-lfs is in (dev block, §8).

## 1. The full desktop

*Aspects: hyprland, hyprglass, autologin, quickshell, terminals, desktop-apps, fonts, theme, ime, xdg*

Ends with the NixOS session: ghostty, quickshell bar, hyprglass, fonts, dots linked, autologin.

### 1.1 GURU

Most desktop packages (quickshell, awww, fuzzel, keyd, …) are in GURU, all `~amd64`.

```bash
sudo eselect repository enable guru && sudo emaint sync -r guru
echo '*/*::guru ~amd64' | sudo tee /etc/portage/package.accept_keywords/guru
```

### 1.2 Packages

From `packages.md`, each with its **before** block: **desktop: session**, **desktop: apps**,
**fonts**.

### 1.3 Session environment

zsh's login shell sources `/etc/profile.d/*.sh` and uwsm inherits it (`/etc/env.d` can't expand
`$HOME`). `/etc/profile.d/p1.sh`:

```bash
export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state" XDG_CACHE_HOME="$HOME/.cache"
export CARGO_HOME="$XDG_DATA_HOME/cargo" RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go" GOBIN="$HOME/.local/bin"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc" NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$HOME/.local"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history" YARN_ENABLE_GLOBAL_CACHE=true
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python" PYTHONUSERBASE="$HOME/.local"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config" KUBECACHEDIR="$XDG_CACHE_HOME/kube"
export ANDROID_HOME="$XDG_DATA_HOME/android/sdk" ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
export WINEPREFIX="$HOME/wine/prefix/default"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PASSWORD_STORE_DIR="$HOME/git/auth/pass" SOPS_AGE_KEY_FILE="$HOME/git/auth/age/keys.txt"
export LESSHISTFILE="$XDG_STATE_HOME/less_history" WGETRC="$XDG_CONFIG_HOME/wgetrc"
export XCOMPOSECACHE="$XDG_CACHE_HOME/X11/xcompose"
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv" PULSE_COOKIE="$XDG_CACHE_HOME/pulse/cookie"
export GTK_THEME=adw-gtk3-dark QT_QPA_PLATFORMTHEME=gtk3
export LIBVA_DRIVER_NAME=iHD
export QT_IM_MODULE=fcitx INPUT_METHOD=fcitx XMODIFIERS=@im=fcitx SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus DefaultIMModule=fcitx
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$CARGO_HOME/bin:$PATH" ;; esac
```

`/etc/xdg/user-dirs.defaults` (empty = `$HOME`, so unused folders aren't created):

```ini
DOWNLOAD=downloads
DESKTOP=desktop
DOCUMENTS=
MUSIC=
PICTURES=
VIDEOS=
TEMPLATES=
PUBLICSHARE=
```

### 1.4 Fonts

TX-02 and Smash ship in dots `assets/`:

```bash
mkdir -p ~/.local/share/fonts && unzip -o ~/git/dots/assets/fonts/TX-02.zip -d ~/.local/share/fonts/TX-02
cp ~/git/dots/assets/fonts/Smash-Regular.ttf ~/.local/share/fonts/
```

`/etc/fonts/local.conf` (look.nix `defaultFonts` + `localConf`):

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias><family>monospace</family><prefer>
    <family>JetBrainsMono Nerd Font</family><family>IosevkaTerm Nerd Font</family>
    <family>Noto Sans Mono CJK JP</family><family>Noto Color Emoji</family></prefer></alias>
  <alias><family>sans-serif</family><prefer>
    <family>Noto Sans</family><family>Noto Sans CJK JP</family><family>Noto Color Emoji</family></prefer></alias>
  <alias><family>serif</family><prefer>
    <family>Noto Serif</family><family>Noto Serif CJK JP</family><family>Noto Color Emoji</family></prefer></alias>
  <alias><family>emoji</family><prefer><family>Noto Color Emoji</family></prefer></alias>
  <alias><family>TX-02</family><prefer>
    <family>JetBrainsMono Nerd Font</family><family>Noto Sans Mono CJK JP</family><family>Noto Color Emoji</family></prefer></alias>
</fontconfig>
```

```bash
fc-cache -f; fc-match monospace; fc-match TX-02
```

fcitx5 autostarts via XDG; add mozc in `fcitx5-configtool` once in the session.

### 1.5 GTK theme + Nemo (dconf)

GTK reads dconf before `gtk-3.0/settings.ini`, so these win. `/etc/dconf/db/local.d/00-p1`:

```ini
[org/cinnamon/desktop/default-applications/terminal]
exec='ghostty'
exec-arg='-e'

[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Adwaita-dark'
font-name='JetBrainsMono Nerd Font 10'
monospace-font-name='JetBrainsMono Nerd Font 14'
document-font-name='Noto Sans 14'
```

`/etc/dconf/profile/user`:

```text
user-db:user
system-db:local
```

```bash
sudo dconf update
xdg-mime default nemo.desktop inode/directory
```

### 1.6 hyprglass

Built by hand, and **rebuilt after every Hyprland update** (plugin ABI). The `make` line works
around two Makefile quirks: Lua headers in `/usr/include/lua5.4/`, and `--no-gnu-unique` only
added when the compiler is literally `g++` (without it the plugin can't reload).

```bash
git clone --branch v0.7.0 --depth 1 https://github.com/hyprnux/hyprglass ~/.cache/hyprglass
make -C ~/.cache/hyprglass clean
make -C ~/.cache/hyprglass CXX=g++ INCLUDES="$(pkg-config --cflags hyprland pixman-1 libdrm lua5.4)"
sudo install -Dm755 ~/.cache/hyprglass/hyprglass.so /usr/local/lib/libhyprglass.so
```

`hyprland.lua` already loads it from `/usr/local/lib` and has no nm-applet.

### 1.7 Dots: `home_setup.sh`

It links `config/` into `~/.config` but won't replace real files, so move Gentoo's defaults aside:

```bash
mkdir -p ~/old-defaults && mv ~/.config/hypr ~/.config/kitty ~/.zshrc ~/old-defaults/
rmdir ~/Downloads ~/ext_ssd 2>/dev/null
cd ~/git/dots
./scripts/home_setup.sh             # dry run: read it
./scripts/home_setup.sh --apply
```

Delete `~/old-defaults` once the session works.

### 1.8 Autologin: tty1 → uwsm → Hyprland

getty autologins tty1 and `config/zsh/.zprofile` runs `uwsm start -e -D Hyprland
hyprland.desktop`. The disk PIN is the only gate at boot.

```bash
sudo systemctl edit getty@tty1
```

```ini
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin meow %I $TERM
```

User services, as meow (no sudo). `hyprland.lua` enables `hypridle.service` itself.

```bash
systemctl --user enable hyprpolkitagent.service
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service
```

### 1.9 Log in

```bash
sudo reboot
```

PIN → Hyprland. Then:

```bash
hyprctl plugin list            # hyprglass
prime-run nvidia-smi           # RTX visible
vainfo | head -3               # iHD
```

Autostart lines for things not installed yet (mpd, mullvad-vpn, vesktop, …) fail quietly.

## 2. SSH, GnuPG, pass

*Aspects: ssh, auth, gpg, pass*

`~/git/auth/ssh/p1` (no passphrase, by design; `auth/CLAUDE.md`) is used for **every** outbound
ssh. `~/.ssh/config`:

```ssh-config
Host sarten
    HostName 192.168.1.135
    User asynthe

Host *
    IdentityFile ~/git/auth/ssh/p1
    IdentitiesOnly yes
    KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,curve25519-sha256
```

```bash
ssh -T git@github.com; ssh -T git@gitlab.com; ssh sarten true
git config --global user.name asynthe
git config --global user.email <same as config/jj [user] email>
git config --global init.defaultBranch main
```

Inbound: auth.nix `meow.keys`, no passwords, no root.

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat > ~/.ssh/authorized_keys <<'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDnUPjUAi2Red+yEOocv3LorVYbA3VHTI6z4QjGX+9T s24
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRuhUZDJsm4KiLYGqo5g2Usd3fvW5Tu+sCr5O5CRaQ8 macbook
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0H7gtdrNpsghM6LQ3jPDoeDkJMQW4/YDfc+DzMF1/j p1
EOF
chmod 600 ~/.ssh/authorized_keys
```

`/etc/ssh/sshd_config.d/p1.conf` (port 22 is only open on `tailscale0`, §4):

```ssh-config
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
```

```bash
sudo systemctl enable --now sshd
```

**GnuPG:** `GNUPGHOME=~/.local/share/gnupg`, pinentry-curses. Don't enable Gentoo's
`gpg-agent.socket` user units: with a custom `GNUPGHOME` they listen in the wrong place.

```bash
mkdir -p "$GNUPGHOME" && chmod 700 "$GNUPGHOME"
echo 'pinentry-program /usr/bin/pinentry-curses' > "$GNUPGHOME/gpg-agent.conf"
gpgconf --kill gpg-agent
```

Add `export GPG_TTY=$(tty)` to `~/git/dots/config/zsh/.zshrc` under the `PASSWORD_STORE_DIR` line,
open a new terminal, then import and fully trust the key (`.gpg-id` must match):

```bash
[ -f ~/git/auth/gpg/private.asc ] || ~/git/auth/decrypt
gpg --import ~/git/auth/gpg/private.asc
echo "$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr/{print $10; exit}'):6:" | gpg --import-ownertrust
gpg --list-secret-keys --keyid-format long
cat "$PASSWORD_STORE_DIR/.gpg-id"
rm ~/git/auth/gpg/private.asc       # private.asc.age stays; decrypt remakes it
```

Expired: `gpg --quick-set-expire <key-id> 2y` and `gpg --quick-set-expire <key-id> 2y '*'`.

**pass:** the store is in the `auth` repo; every change is a commit there, and `pass git push`
pushes it.

| | |
|---|---|
| `pass` / `pass show sarten` / `pass -c sarten` | tree / print / copy (cleared after 45 s) |
| `pass insert email/new` / `pass generate dev/new 32` | add typed / random |
| `pass edit sarten` / `pass grep -i github` | edit / search |

## 3. Network

*Aspect: network*

iwd (with its own DHCP) + systemd-resolved were set up in install step 15. impala isn't
packaged: `cargo install impala`. Then run the **not used** block from `packages.md`.

## 4. Kernel params, lid, firewall

*Aspect: laptop (+ p1 kernelParams)*

Append to the line in `/etc/kernel/cmdline` (`notes/structure/p1.md`):

| Param | Why |
|---|---|
| `i915.enable_psr=0` | panel self-refresh blanks the internal display |
| `video=DP-1:d` | DP-1 is a phantom (stale EDID) that Hyprland would focus |

```bash
sudo emerge --config sys-kernel/gentoo-kernel    # new UKI; its own PCR11 signature, PIN still works
```

`/etc/systemd/logind.conf.d/lid.conf`:

```ini
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
```

**Firewall** (NixOS had one; stock Gentoo doesn't). Only this table gets reloaded, so tailscale,
mullvad and libvirt keep theirs. Ports: 41641 tailscale, 22000/21027 syncthing, 270xx Steam.
`/etc/nftables.d/p1.nft`:

```text
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
```

`/etc/systemd/system/p1-firewall.service`:

```ini
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
```

```bash
sudo nft -c -f /etc/nftables.d/p1.nft && sudo systemctl enable --now p1-firewall
sudo nft list table inet p1
```

## 5. Firefox: arkenfox + policies

*Aspect: firefox*

firefox-bin in `/opt/firefox`, with system-wide autoconfig and policies, so every profile
(default, study, work, infra) gets the same prefs and add-ons. **Close Firefox first.**

Scripts and links call plain `firefox`; firefox-bin only installs `firefox-bin`, and its desktop
entry clashes with the default profile's remoting name. `-P default` stops a new install from
creating an empty profile.

```bash
sudo ln -sf /usr/bin/firefox-bin /usr/local/bin/firefox
mkdir -p ~/.local/share/applications
printf '[Desktop Entry]\nType=Application\nName=Firefox\nExec=firefox -P default %%u\nIcon=firefox-bin\nTerminal=false\nCategories=Network;WebBrowser;\nMimeType=application/pdf;application/xhtml+xml;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;\n' > ~/.local/share/applications/firefox.desktop
xdg-settings set default-web-browser firefox.desktop
printf '%s\n' 'pref("general.config.filename", "mozilla.cfg");' 'pref("general.config.obscure_value", 0);' \
  | sudo tee /opt/firefox/defaults/pref/autoconfig.js
```

`mozilla.cfg` = arkenfox (`user_pref` → `defaultPref`) + `common.cfg`. Rerun to update arkenfox:

```bash
curl -fsSL https://raw.githubusercontent.com/arkenfox/user.js/master/user.js \
  | sed 's/^user_pref(/defaultPref(/' > /tmp/arkenfox.cfg
{ echo '// p1 autoconfig'; cat /tmp/arkenfox.cfg ~/git/dots/config/firefox/common.cfg; } \
  | sudo tee /opt/firefox/mozilla.cfg >/dev/null
```

Policies (add-ons + theme) come from the `ADDONS` array in `scripts/firefox/policies.sh`. Edit it,
then rerun: dry run first, `--apply` writes `/etc/firefox/policies/policies.json`.

```bash
~/git/dots/scripts/firefox/policies.sh
~/git/dots/scripts/firefox/policies.sh --apply
for p in default study work infra; do sed -i '/"extensions.activeThemeID"/d' ~/.config/mozilla/firefox/$p/prefs.js; done
```

The `sed` clears a theme a profile saved itself, so `common.cfg`'s wins. Check `about:policies`
and `general.config.filename` in `about:config`. Profiles come from `scripts/firefox/setup.sh`
(run by `home_setup.sh`, §1.7).

## 6. Hardware

*Aspects: audio, bluetooth, controller, hhkb, colord, android, intel-gpu, nvidia-prime, fingerprint, tpm*

**Packages:** `packages.md` → **hardware**. dualsensectl isn't packaged; xpadneo is a signed
kernel module. For JACK apps: `echo 'media-video/pipewire jack-sdk' | sudo tee -a /etc/portage/package.use/p1`.

**HHKB:** ◇ keys (Muhenkan/Henkan) → meta, for `04fe:0021` only. `/etc/keyd/hhkb.conf`:

```ini
[ids]
04fe:0021

[main]
muhenkan = leftmeta
henkan = rightmeta
```

```bash
sudo systemctl enable --now keyd colord bluetooth
sudo usermod -aG tss,kvm meow                              # next login
sudo ln -s /usr/bin/prime-run /usr/local/bin/nvidia-offload  # ES-DE's wrapper calls it
```

Bluetooth on at boot: `AutoEnable=true` under `[Policy]` in `/etc/bluetooth/main.conf`. NPU:
`ivpu` is in the kernel; add userspace only if needed.

### nvidia

Open kernel module. dGPU power management, `/etc/modprobe.d/nvidia-pm.conf`:

```text
options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1
```

```bash
sudo systemctl enable nvidia-powerd
sudo emerge --config sys-kernel/gentoo-kernel
```

Suspend is handled by the driver (no `nvidia-suspend` units since 595.x). After a reboot:

```bash
grep -E 'DynamicPower|PreserveVideo|SuspendNotif' /proc/driver/nvidia/params   # 2 / 1 / 1
```

Hyprland runs on the Arc; `prime-run <app>` for the RTX.

### fwupd

`sudoedit /etc/fwupd/fwupd.conf` (no comments on value lines). `EspLocation`: there's no
udisks2. `DisableShimForSecureBoot`: no shim; `fwupdx64.efi.signed` is signed with the sbctl key.

```ini
[uefi_capsule]
EspLocation=/efi
DisableShimForSecureBoot=true
```

```bash
sudo systemctl restart fwupd
sbverify --list /usr/libexec/fwupd/efi/fwupdx64.efi.signed     # issuer CN=Database Key
sudo fwupdmgr refresh && sudo fwupdmgr get-updates
```

`sudo fwupdmgr update` on AC power; it may reboot twice. BIOS and db/dbx updates change PCR7:
unlock with the passphrase once, then re-enroll (install step 18).

### Fingerprint

| | |
|---|---|
| Disk | TPM PIN |
| tty1 | autologin |
| sudo, hyprlock | fingerprint, or meow's password |

Enroll as meow (no sudo):

```bash
fprintd-enroll                     # right index finger
fprintd-enroll -f left-index-finger
fprintd-verify
```

hyprlock, `~/.config/hypr/hyprlock.conf` (a dots file, check it first):

```text
auth {
    fingerprint:enabled = true
}
```

sudo: keep a root shell open on tty2 (`sudo -i`) until this works, since a broken PAM file locks
you out of sudo. First `auth` line of `/etc/pam.d/sudo` (`sudoedit /etc/pam.d/sudo`):

```text
auth       sufficient   pam_fprintd.so max-tries=2 timeout=10
```

```bash
sudo -k; sudo true && echo sudo-ok   # finger; 2 misses or 10 s, then the password
```

Over ssh it skips straight to the password. Optional: the same line in `/etc/pam.d/login`.

## 7. Dotfile leftovers (in `~/git/dots`)

NixOS-only paths. Edit, test, commit.

| File | Change |
|---|---|
| `config/ES-DE/custom_systems/es_find_rules.xml:7` | `/run/current-system/sw/lib/retroarch/cores` → RetroArch's cores (§12) |
| `config/yazi/theme.toml:109` | `syntect_theme` is a `/nix/store` path → copy the `.tmTheme` into `config/yazi` |
| `config/bash/bashrc:81` | delete `alias rebuild='doas nixos-rebuild switch'` |
| `config/zsh/.zsh_functions` | delete `nix-clean`, `nix-roots` (or rewrite around `emerge --depclean`) |
| `nix/`, `flake.*`, `secrets/`, `.sops.yaml`, `auth.nix` | keep for reference or delete |

## 8. Dev

*Aspects: git, neovim, python, javascript, database, database-gui, dbt, infra, vscodium, web-dev, work, cli (direnv)*

**Packages:** `packages.md` → **dev**.

```bash
git lfs install && git -C ~/git/dots lfs pull
npm i -g @fsouza/prettierd eslint_d
go install mvdan.cc/sh/v3/cmd/shfmt@latest
go install github.com/xo/usql@latest
uv tool install harlequin; uv tool install sqlfluff
uv tool install dbt-core --with dbt-postgres
```

Python libraries in one venv (polars isn't in ::gentoo, and PEP 668 blocks system pip). Use it with
`source ~/.local/share/py/bin/activate`; for projects, direnv `layout uv`.

```bash
uv venv ~/.local/share/py && VIRTUAL_ENV=~/.local/share/py uv pip install \
  numpy pandas polars pyarrow scipy scikit-learn matplotlib seaborn plotly jupyterlab ipython \
  sqlalchemy openpyxl requests httpx black isort mypy mutagen
```

VSCodium (Open VSX; `open-remote-ssh` replaces `remote-ssh`):

```bash
for e in anthropic.claude-code asvetliakov.vscode-neovim bbenoist.nix enkia.tokyo-night \
  mechatroner.rainbow-csv ms-azuretools.vscode-docker ms-python.python \
  jeanp413.open-remote-ssh shd101wyy.markdown-preview-enhanced yzhang.markdown-all-in-one \
  zhuangtongfa.material-theme; do codium --install-extension "$e"; done
```

cursor and postman: Flatpak (§13) or AppImage.

**PostgreSQL 17**, database `play` owned by meow, trusted on loopback:

```bash
sudo emerge --config dev-db/postgresql:17
```

Rules in `/etc/postgresql-17/pg_hba.conf`:

```text
local all all              trust
host  all all 127.0.0.1/32 trust
host  all all ::1/128      trust
```

```bash
sudo systemctl enable --now postgresql-17
sudo -u postgres createuser --superuser meow && createdb play
```

## 9. Virtualisation

*Aspect: virtualisation*

**Packages:** `packages.md` → **virt**. The `for` line stops libvirt networks from autostarting
(NixOS did it with a oneshot). virtio-win ISO: fedorapeople, when needed.

```bash
echo 'options kvm_intel nested=1' | sudo tee /etc/modprobe.d/kvm.conf
sudo usermod -aG libvirt meow
sudo systemctl enable --now libvirtd
for n in $(sudo virsh net-list --all --name); do sudo virsh net-autostart --disable "$n"; done
```

## 10. Network services

*Aspects: tailscale, mullvad, mullvad-tailscale, syncthing, wazuh-syslog, net-tools, soc-tools*

**Packages:** `packages.md` → **net**. In `systemctl edit tailscaled`, add
`Environment=TS_DEBUG_FIREWALL_MODE=nftables` under `[Service]`.

```bash
sudo systemctl edit tailscaled
sudo systemctl enable --now tailscaled && sudo tailscale up
sudo systemctl enable --now mullvad-daemon
```

Mullvad swallows the tailnet; this table lets tailnet traffic bypass the tunnel. **The hook
priorities matter** (`net/vpn.nix`). Append to `/etc/nftables.d/p1.nft`:

```text
table inet mullvad-tailscale {}
delete table inet mullvad-tailscale
table inet mullvad-tailscale {
    chain output {
        type route hook output priority 0; policy accept;
        ip  daddr 100.64.0.0/10       ct mark set 0x00000f41 meta mark set 0x6d6f6c65
        ip6 daddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
    }
    chain input {
        type filter hook input priority -100; policy accept;
        ip  saddr 100.64.0.0/10       ct mark set 0x00000f41 meta mark set 0x6d6f6c65
        ip6 saddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
    }
}
```

```bash
sudo systemctl reload p1-firewall
systemctl --user enable --now syncthing.service    # your user; GUI at 127.0.0.1:8384
```

**wazuh-syslog**, `/etc/rsyslog.d/90-wazuh.conf`:

```text
module(load="imjournal" StateFile="imjournal.state")
*.* action(type="omfwd" target="192.168.1.142" port="514" protocol="udp" template="RSYSLOG_TraditionalForwardFormat")
```

```bash
sudo systemctl enable --now rsyslog
```

## 11. Pentest (optional)

*Aspect: pentest*

**Packages:** `packages.md` → **pentest**. Don't enable ::pentoo (it overrides system packages).

```bash
sudo usermod -aG pcap meow          # Wireshark without root
go install github.com/ffuf/ffuf/v2@latest
go install github.com/OJ/gobuster/v3@latest
go install github.com/projectdiscovery/{nuclei/v3/cmd/nuclei,subfinder/v2/cmd/subfinder,katana/cmd/katana}@latest
go install github.com/owasp-amass/amass/v4/...@master
go install github.com/jpillora/chisel@latest
cargo install feroxbuster
uv tool install netexec; uv tool install dnsrecon; uv tool install mitmproxy
```

When needed: burpsuite, metasploit (omnibus), seclists (clone into `~/archive`), exploitdb,
wpscan, bettercap, responder, smbmap, enum4linux-ng, whatweb, cewl, hashid, ligolo-ng, setoolkit.

## 12. Games

*Aspects: steam, wine, lutris, osu-lazer, stepmania, star-citizen, emulators, uzdoom*

**Packages:** `packages.md` → **games** (its **before** block keywords the newest wine-staging,
sets `wow64`, enables steam-overlay). Then check MusicBee; 11.16 once broke it.

```bash
eselect wine list          # the installed wine-staging is marked *
```

- **Steam:** native, in the block. Its 32-bit deps need `--autounmask-write`, `dispatch-conf`,
  rerun. Lighter: Flatpak `com.valvesoftware.Steam`.
- **In the block:** dolphin, pcsx2, ppsspp, azahar, rpcs3, eden.
- **Flatpak:** RetroArch (`org.libretro.RetroArch`), Cemu (`info.cemu.Cemu`), Ryubing, ITGmania.
- **AppImage** into `~/.local/bin`: Xenia-canary, ES-DE (wrapper from `emulation.nix`:
  `ESDE_APPDATA_DIR` + `nvidia-offload`). Then fix ES-DE's find rules (§7).
- **Star Citizen:** Lutris "RSI Launcher".
- **BIOS links:** `home_setup.sh` makes them once `~/archive/roms/bios` exists.

## 13. Apps + CLI

*Aspects: flatpak, gimp, kiwix, monero, qbittorrent, irc, music, tectonic, typst, atuin, cli*

**Packages:** `packages.md` → **apps**, then **cli**.

```bash
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

## 14. Shared account (kazu)

*auth.nix `shared` (uid 1001, group `share`) + share.nix bind mounts*

Bind mounts, not symlinks (a symlink would need traverse permission on `/home/meow`).

```bash
sudo groupadd share && sudo usermod -aG share meow
sudo useradd -m -u 1001 -G share -s /bin/zsh shared && sudo passwd -l shared
sudo install -d -m700 -o shared -g shared /home/shared/.ssh
```

`/home/shared/.ssh/authorized_keys`: the two kazu keys from auth.nix (owner `shared`, mode 600).

Append to `/etc/fstab` (`nofail`: a missing source never blocks boot):

```text
/home/meow/archive/media/anime    /home/shared/anime    none bind,nofail 0 0
/home/meow/archive/arcade         /home/shared/arcade   none bind,nofail 0 0
/home/meow/archive/media/book     /home/shared/book     none bind,nofail 0 0
/home/meow/archive/games          /home/shared/games    none bind,nofail 0 0
/home/meow/archive/media/movies   /home/shared/movies   none bind,nofail 0 0
/home/meow/archive/media/music    /home/shared/music    none bind,nofail 0 0
/home/meow/archive/roms           /home/shared/roms     none bind,nofail 0 0
/home/meow/archive/media/series   /home/shared/series   none bind,nofail 0 0
/home/meow/archive/media/youtube  /home/shared/youtube  none bind,nofail 0 0
```

```bash
sudo -u shared mkdir -p /home/shared/{anime,arcade,book,games,movies,music,roms,series,youtube}
sudo systemctl daemon-reload && sudo mount -a && findmnt -t none | grep /home/shared
```

Group-writable ACLs (NixOS's tmpfiles `A+`). `games/` has ~300k files, so it's slow:

```bash
for d in media/anime arcade media/book games media/movies media/music roms media/series media/youtube; do
  setfacl -R -m g:share:rwX -m d:g:share:rwX ~/archive/$d; done
```

## 15. Not coming over

| NixOS | Here |
|---|---|
| impermanence | btrfs `@` + `@snapshots`; snapper later if wanted |
| sops-nix for passwords | `/etc/shadow`; sops/age stay for `~/git/auth` |
| nh, cachix, nix-direnv, star-citizen-cache, flannel overlay | Nix only |
| hermes (hermes-agent service) | not packaged; later: `uv tool install` from its repo + token from `sops -d ~/git/dots/secrets/secrets.yaml` + a user service |
| `services.getty.autologinOnce` | systemd has no "once"; tty1 autologins every boot |
| sudo timestamp/lecture settings | sudo defaults (5 min per terminal) |

## 16. Check

`emerge -pv @world` should have nothing pending, and the last line should print nothing.

```bash
systemctl --failed; systemctl --user --failed
hyprctl plugin list
prime-run nvidia-smi
vainfo | head -3
busctl --system tree net.connman.iwd | head     # the bar's network source
tailscale status; mullvad status
sudo nft list ruleset | grep -c table
emerge -pv @world | tail -1
comm -13 <(grep -oE '^  [a-z0-9-]+/[^ ]+' ~/git/dots/gentoo/packages.md | tr -d ' ' | sort -u) <(sort /var/lib/portage/world)
```


## 17. Last: `~amd64`, then Graphite / LTO / PGO

Newest versions, built as fast as the hardware allows. Last on purpose: stable + binhost gets a
usable desktop fast, then this rebuilds most of the system from source while you work.

The cost: much more compiling (the binhost is mostly stable and ignores your flags; `-bin`
packages stay prebuilt) and occasional breakage. The previous kernel stays in the boot menu until
`depclean`. Dry run on 2026-10-01: 265 packages, 258 from source (kernel 7.2, glibc 2.44,
systemd 262, Mesa 26.2, nvidia 615, LLVM 23), many hours.

`scripts/04-amd64.sh` does all of it in stages; read a stage's case block before running it.
Run every stage except `prep` on **tty2 in tmux**: a terminal inside Hyprland dies with the
session. CTRL+ALT+F2, log in, `tmux new -s world` (or `tmux attach -t world`); back to Hyprland
with CTRL+ALT+F1, watch with `tmux attach -t world` (CTRL+B D detaches). Each emerge blocks
sleep, idle and the lid switch, and its output is kept in `~/.local/state/p1-setup/logs/`.
Each runs in its own systemd scope with `OOMPolicy=continue`: run straight inside tmux, one
compiler killed for memory makes systemd stop tmux's whole scope, emerge included (2026-10-15,
qtwebengine and qtmultimedia at `-j15` each). Chromium-sized builds (qtwebengine, webkit-gtk)
get `-j6` from `/etc/portage/package.env/heavy`. Start emerges through the script, not by hand.

```bash
cd ~/git/dots/gentoo/scripts
./04-amd64.sh prep        # tmux; /var/tmp/portage on tmpfs (24G), the biggest builds on disk
./04-amd64.sh stage1      # tty2 + tmux: snapshot, ~amd64, USE lto pgo, gcc graphite/lto/pgo,
                          # world update + every remaining packages.md block but games
./04-amd64.sh resume      # only if stage1 got interrupted: continues portage's saved queue
./04-amd64.sh hyprglass   # against the new Hyprland (also after any later Hyprland update)
```

Before rebooting into the new kernel, its nvidia module must exist, or 7.2 boots without the
dGPU:

```bash
sudo emerge -av @preserved-rebuild
sudo dispatch-conf
find /lib/modules/7.2.*/ -name 'nvidia.ko*'     # one per new kernel
```

In `dispatch-conf`, **z** (zap new, keep yours) for any file you edited: `/etc/fstab`,
`/etc/pam.d/*`, `/etc/sudoers`, `/etc/bluetooth/main.conf`, `/etc/fwupd/fwupd.conf`. **u** (use new)
only for files you never touched. Before rebooting, check `sudo -v` still works in a second
terminal.

Reboot, then:

```bash
uname -r                    # 7.2.x
lsmod | grep nvidia         # signed modules load under Secure Boot
hyprctl plugin list         # hyprglass
systemctl --failed
```

Then §18 (tuning: at least `makeconf scx power`, so stage2 runs at idle priority), and:

```bash
sudo emerge -pvuDN @world # nothing pending
sudo emerge -a --depclean # also removes the old kernel: only once the new one booted fine
./04-amd64.sh stage2      # snapshot, -flto=auto -fno-semantic-interposition, binhost off,
                          # emerge -e @world (many hours again)
./04-amd64.sh failed      # rebuilds whatever failed in stage2 without LTO, lists it in no-lto
./04-amd64.sh games       # interactive: Steam's autounmask + dispatch-conf, the gpm/ncurses fix
```

games comes after stage2 on purpose: `-e @world` rebuilds everything installed, so games built
before it (wine, rpcs3, dolphin, pcsx2, …) would compile twice.

What each part buys:

| | Where | Effect |
|---|---|---|
| `-march=meteorlake` | make.conf (install) | Every instruction the CPU has. The biggest single gain. |
| `USE="lto pgo"` | stage1 | Only packages that offer them: python, bash, xz, binutils, svt-av1, rust (`lto`). Python PGO is ~10–20% faster. |
| gcc `graphite lto pgo` | stage1 | A faster compiler: shorter builds from here on. |
| `-flto=auto` | stage2 | Whole-program optimisation everywhere: a few percent in places, smaller binaries. |
| `-fno-semantic-interposition` | stage2 | Calls inside a shared library can be inlined. Only breaks code that `LD_PRELOAD`s a library's own internal symbols. |

Left out on purpose:
- **Graphite loop flags** (`-fgraphite-identity -floop-nest-optimize`): gcc is built with
  Graphite so they work, but the gains are tiny and they're the likeliest source of silent
  miscompiles.
- **`-O3`, `-fipa-pta`, `-fdevirtualize-at-ltrans`** (what GentooLTO used): small gains for much
  longer builds, more RAM and more breakage. GentooLTO itself is in maintenance mode and points to
  upstream LTO, which is what stage2 does; its workaround lists date from 2019.
- **clang/LLVM as the system compiler:** about the same speed as gcc LTO, more breakage. The
  clang ebuild has no `lto`/`pgo` flag, and llvm drops `lto` when built with gcc.

Rollback: stage1 and stage2 each take a read-only btrfs snapshot of `/` first
(`/.snapshots/@-pre-amd64-*`, `@-pre-lto-*`), and keep a copy of `make.conf`
(`make.conf.stable.bak`, `make.conf.prelto.bak`).

## 18. Tuning

`scripts/06-tune.sh`, after the reboot into the new kernel and with no emerge running. Each step
shows itself and asks; `./06-tune.sh scx boot` runs only those. Packages: `packages.md` → **tune**.

- **makeconf:** `GOAMD64="v3"` (Go's `-march`), builds at idle CPU and IO priority
  (`PORTAGE_SCHEDULING_POLICY`, `PORTAGE_IONICE_COMMAND`; a build crawls while you play),
  `FEATURES` parallel-install.
- **scx:** sched-ext, `scx_lavd` in Auto mode via `scx_loader`: a scheduler made for interactive
  and gaming loads, aware of the P/E/LP-E cores. On any error the kernel falls back to the normal
  scheduler by itself. `scxtop` shows it working; `default_sched = "scx_bpfland"` in
  `/etc/scx_loader/config.toml` is the alternative; `sudo systemctl disable --now scx_loader` turns
  it off.
- **power:** power-profiles-daemon only (`powerprofilesctl set performance|balanced|power-saver`).
  thermald exits on this ThinkPad ("dytc_lapmode present: can't run on this platform"): the
  firmware does thermals, driven by power-profiles-daemon. The step disables and deselects it.
- **mold:** fast linker, opt-in per package (`/etc/portage/package.env/mold`), not global: untested
  with LTO.
- **cache:** sccache for every `cargo build` (`~/.cargo/config.toml`), ccache for your own C/C++
  (20G). Not for portage globally: a cache only hits on the same source with the same flags, and
  `~amd64` bumps versions while stage2 changes every flag. Opt-in per package instead
  (`/etc/portage/package.env/ccache`) for a big package rebuilt at the same version.
- **boot:** `systemd-analyze` blame and critical chain, read-only.

## 19. Final state

Global settings live in `make.conf`; `package.env` only holds per-package exceptions (`notmpfs`,
`no-lto`, `mold`, `ccache`). After §17 and §18, `/etc/portage/make.conf` is the install one
(install step 9) plus:

```bash
COMMON_FLAGS="-march=meteorlake -mabm -mshstk -mno-kl -mno-pconfig -mno-sgx -mno-widekl -O2 -pipe -flto=auto -fno-semantic-interposition"
GOAMD64="v3"
FEATURES="parallel-fetch parallel-install"          # getbinpkg + binpkg-request-signature gone
PORTAGE_SCHEDULING_POLICY="idle"
PORTAGE_IONICE_COMMAND="ionice -c 3 -p \${PID}"
USE="wayland pipewire vaapi vulkan dist-kernel systemd bluetooth secureboot modules-sign -gnome -kde lto pgo"
ACCEPT_KEYWORDS="~amd64"
```

```bash
grep -vE '^\s*(#|$)' /etc/portage/make.conf       # compare
cat /etc/portage/package.env/*                    # the exceptions
```

**Maintenance:**
- Updates: `sudo emerge -avuDN @world` in tmux on tty2, then `sudo emerge -av @preserved-rebuild`
  and `sudo dispatch-conf`. A package that breaks with LTO: `./04-amd64.sh failed`.
- After a Hyprland update: `./04-amd64.sh hyprglass`.
- `sudo emerge -a --depclean` after kernel updates removes old kernels and their UKIs, once the
  new one has booted.
- After a BIOS or Secure Boot change, re-enroll the TPM (install step 18).
