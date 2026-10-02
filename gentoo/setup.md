# Gentoo on p1: setup

Part 2, after `install.md`. The install ends at a working tty, and this file turns that into the
NixOS system: Hyprland first, then everything else. Everything here is done by hand, by
copy-pasting the blocks.

The source of truth is `~/git/dots/nix` (the NixOS flake, as of commit ee0d0bf).
`nix/hosts/p1/default.nix` lists every aspect p1 imported. Each section here names the aspects
it replaces, so to answer "is X done?", search this file for the aspect name. Written
2026-10-01, with package names checked against ::gentoo, ::hyproverlay and ::guru that day.

## Status 2026-10-01

- **Done:** install, fwupd (BIOS 1.21), TPM+PIN, §0
- **Done:** §2 SSH. The p1 key is verified on github (asynthe), gitlab (@asynthe) and sarten.
- **Partly done:** §1 (guru, uwsm, desktop packages were emerging) and §4 (firewall)

> **This install only: firmware fix first.** Install step 13 used to put `linux-firmware` before
> the kernel. Its postinst failed and stopped the emerge, so `linux-firmware` and `intel-microcode`
> were never installed. Wi-Fi only works from the firmware copy inside the current UKI, and the
> next UKI rebuild (§4, §6) would drop it. Fix: paste the **base** block from `packages.md`
> (this also records gentoo-kernel in @world; nothing gets rebuilt), then check:
>
> ```bash
> ls -d /var/db/pkg/sys-kernel/linux-firmware-* /var/db/pkg/sys-firmware/intel-microcode-*
> sudo lsinitrd $(ls /efi/EFI/Linux/*.efi | tail -1) | grep -E 'GenuineIntel.bin|iwlwifi-gl'
> ```

## Rules

Same as `install.md`, plus:

1. **Packages aren't in this file.** Each section says which block of `packages.md` to paste.
   That file is the list of everything installed, so add a new package there first.
2. Read the `-a` list before saying yes. Everything here runs on **stable** (prebuilt binaries,
   fast), so testing-only packages get `~amd64` lines. §17, the very last step, switches the
   whole system to `~amd64`, and Graphite/LTO/PGO come after that.
3. Nothing from NixOS that only existed because of Nix comes over (see §15).
4. Paste long commands on **one line**, or keep the ` \` continuations.

---

## 0. Get the dots

Right after the install, at the tty. Type these by hand: there's nothing to paste from yet. The
dots repo is public, so https works without a key (like `scripts/bootstrap.sh` does).

```bash
mkdir -p ~/git
git clone https://gitlab.com/asynthe/dots.git ~/git/dots
rm -r ~/gentoo
```

From here the guides live in `~/git/dots/gentoo/`. The wallpapers are in git-lfs: run
`git -C ~/git/dots lfs pull` once git-lfs is installed (the dev block).

## 1. Hyprland: the full desktop, first

*Aspects: hyprland, hyprglass, autologin, quickshell, terminals, desktop-apps, fonts, theme, ime, xdg*

By the end of this section the laptop boots into the same Hyprland session NixOS had: ghostty,
quickshell bar, hyprglass, fonts, all your dots linked.

### 1.0 Something to paste in

From the bare tty, type these four lines by hand. They give you a plain Hyprland and kitty, so
the rest of this file can be copy-pasted.

```bash
sudo eselect repository enable hyproverlay && sudo emaint sync -r hyproverlay
echo '*/*::hyproverlay ~amd64' | sudo tee /etc/portage/package.accept_keywords/hyproverlay
sudo emerge -av gui-wm/hyprland x11-terms/kitty media-fonts/dejavu
start-hyprland
```

Hyprland writes a default config on first start. **SUPER+Q** opens kitty, and **SUPER+M** exits.
In kitty, open this file (`nvim ~/git/dots/gentoo/setup.md`); kitty copies with **CTRL+SHIFT+C**
and pastes with **CTRL+SHIFT+V**.

### 1.1 GURU repo

Most desktop packages (quickshell, awww, fuzzel, keyd, …) live in GURU, and every GURU package is
`~amd64`.

```bash
sudo eselect repository enable guru
sudo emaint sync -r guru
echo '*/*::guru ~amd64' | sudo tee /etc/portage/package.accept_keywords/guru
```

### 1.2 Packages

Paste these blocks from `packages.md`, each with its **before** block first:

1. **desktop: session**: Hyprland, uwsm, quickshell, awww, mako, fuzzel, nvidia, pipewire
2. **desktop: apps**: ghostty, kitty, firefox-bin, yazi, nemo, mpv, …
3. **fonts**: nerdfonts (JetBrainsMono, IosevkaTerm, …), noto, CJK, fcitx5 + mozc

### 1.3 Session environment

This replaces `environment.sessionVariables` from the xdg, theme, ime and intel-gpu aspects. zsh's
login shell sources `/etc/profile.d/*.sh`, and uwsm inherits that. (`/etc/env.d` can't be used,
because it doesn't expand `$HOME`.)

`/etc/profile.d/p1.sh`:

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

XDG user dirs, in `/etc/xdg/user-dirs.defaults`. An empty value means `$HOME`, which stops unused
folders from being created.

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

TX-02 and Smash aren't packaged. They ship in the dots `assets/`:

```bash
mkdir -p ~/.local/share/fonts && unzip -o ~/git/dots/assets/fonts/TX-02.zip -d ~/.local/share/fonts/TX-02
cp ~/git/dots/assets/fonts/Smash-Regular.ttf ~/.local/share/fonts/
```

The fontconfig defaults plus the TX-02 fallback alias (look.nix `defaultFonts` + `localConf`),
in `/etc/fonts/local.conf`:

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

fcitx5 starts through XDG autostart (uwsm runs it). Add mozc in `fcitx5-configtool` once you're
in the session.

### 1.5 GTK theme + Nemo (dconf)

GTK reads dconf **before** `gtk-3.0/settings.ini`, so these keys win (dots `CLAUDE.md`).
`/etc/dconf/db/local.d/00-p1`:

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

A Hyprland plugin, built by hand. It **must be rebuilt after every Hyprland update**, because the
plugin ABI changes. After an update, rerun the last three lines and log in again.

Two Gentoo quirks in its Makefile, handled by the `make` line:
- Lua's headers are in `/usr/include/lua5.4/`, which the Makefile never asks pkg-config for,
  so `lauxlib.h` isn't found.
- It only adds `--no-gnu-unique` when the compiler is literally named `g++` (Gentoo's is
  `x86_64-pc-linux-gnu-g++`). Without that flag Hyprland can't cleanly unload or reload the
  plugin, so `CXX=g++`.

```bash
git clone --branch v0.7.0 --depth 1 https://github.com/hyprnux/hyprglass ~/.cache/hyprglass
make -C ~/.cache/hyprglass clean
make -C ~/.cache/hyprglass CXX=g++ INCLUDES="$(pkg-config --cflags hyprland pixman-1 libdrm lua5.4)"
sudo install -Dm755 ~/.cache/hyprglass/hyprglass.so /usr/local/lib/libhyprglass.so
```

Checked 2026-10-01 (hyprglass v0.7.0, Hyprland 0.56.2): builds, with only deprecation warnings
from Hyprland's headers.

### 1.7 Two Gentoo fixes in `hyprland.lua`

`hyprland.lua` loads hyprglass from a NixOS-only path and starts nm-applet (there's no
NetworkManager after §3). Fix both in the repo:

```bash
sed -i 's|/run/current-system/sw/lib/libhyprglass.so|/usr/local/lib/libhyprglass.so|' ~/git/dots/config/hypr/hyprland.lua
sed -i '/nm-applet --indicator/d' ~/git/dots/config/hypr/hyprland.lua
grep -n 'libhyprglass\|nm-applet' ~/git/dots/config/hypr/hyprland.lua
```

The rest of the NixOS-only paths don't block the session. They're in §7.

### 1.8 Dots: `home_setup.sh`

`home_setup.sh` links `config/` into `~/.config`. It won't replace real directories or files, and
these exist from Gentoo's defaults (Hyprland's generated config, kitty, the stage3 `.zshrc`). Move
them aside first:

```bash
mkdir -p ~/old-defaults && mv ~/.config/hypr ~/.config/kitty ~/.zshrc ~/old-defaults/
rmdir ~/Downloads ~/ext_ssd 2>/dev/null
cd ~/git/dots
./scripts/home_setup.sh             # dry run: read it
./scripts/home_setup.sh --apply
```

Delete `~/old-defaults` once the session works.

### 1.9 Autologin on tty1 → uwsm → Hyprland

This is the same flow as NixOS: getty autologins tty1, and `config/zsh/.zprofile` runs
`uwsm start -e -D Hyprland hyprland.desktop`. There's no greeter, so the disk PIN is the only
gate at boot.

```bash
sudo systemctl disable greetd
sudo systemctl edit getty@tty1
```

Paste this into the editor `systemctl edit` opens:

```ini
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin meow %I $TERM
```

Your user services: the polkit agent and audio. Run as meow, **without** sudo.

```bash
systemctl --user enable hyprpolkitagent.service
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service
```

`hypridle.service` gets enabled by `hyprland.lua` itself at startup. NixOS's user unit
`hyprland-dpms-resume` hung off `suspend.target`, which a user manager never reaches, so it never
ran and isn't ported.

### 1.10 Log in

```bash
sudo reboot
```

After the PIN, tty1 logs in by itself and Hyprland starts. Check:

```bash
hyprctl plugin list            # hyprglass loaded
prime-run nvidia-smi           # RTX visible
vainfo | head -3               # iHD driver
```

Autostart lines for things that aren't installed yet (mpd, mullvad-vpn, vesktop, …) just fail
quietly until their section is done.

## 2. SSH: p1 is the personal key

*Aspects: ssh, auth (auth.nix keys)*

`p1` = `~/git/auth/ssh/p1` (no passphrase, by design; see `auth/CLAUDE.md`). It's used for
**every** outbound ssh: github, gitlab, sarten, m2. Already done 2026-10-01: `~/.ssh/config`

```ssh-config
Host sarten
    HostName 192.168.1.135
    User asynthe

Host *
    IdentityFile ~/git/auth/ssh/p1
    IdentitiesOnly yes
    KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,curve25519-sha256
```

All three should authenticate:

```bash
ssh -T git@github.com; ssh -T git@gitlab.com; ssh sarten true
```

`~/git/auth/CLAUDE.md` still says "one key per device, never copied". Update that rule there if
p1 now goes to other machines too.

Git identity: there's no `~/.gitconfig` yet, but jj already has one in `config/jj`. Use the same values:

```bash
git config --global user.name asynthe
git config --global user.email <same as config/jj [user] email>
git config --global init.defaultBranch main
```

Inbound (sshd) uses the same keys as auth.nix `meow.keys`, with password and root login off:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat > ~/.ssh/authorized_keys <<'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDnUPjUAi2Red+yEOocv3LorVYbA3VHTI6z4QjGX+9T s24
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRuhUZDJsm4KiLYGqo5g2Usd3fvW5Tu+sCr5O5CRaQ8 macbook
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0H7gtdrNpsghM6LQ3jPDoeDkJMQW4/YDfc+DzMF1/j p1
EOF
chmod 600 ~/.ssh/authorized_keys
```

`/etc/ssh/sshd_config.d/p1.conf`:

```ssh-config
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
```

```bash
sudo systemctl enable --now sshd
```

Port 22 is reachable over Tailscale only: the §4 firewall trusts `tailscale0`, and nothing else
opens 22.

### GnuPG + password-store

*Aspects: gpg, pass*

`GNUPGHOME` is `~/.local/share/gnupg` and `PASSWORD_STORE_DIR` is `~/git/auth/pass` (both set in
`/etc/profile.d/p1.sh` and `config/zsh/.zshrc`). The key comes from `~/git/auth/gpg/private.asc`,
which `~/git/auth/decrypt` makes from `private.asc.age`. pinentry is curses, like NixOS.

GnuPG warns about a keyring other users can read (`unsafe permissions`), so lock it down, then
set the pinentry:

```bash
mkdir -p "$GNUPGHOME" && chmod 700 "$GNUPGHOME"
echo 'pinentry-program /usr/bin/pinentry-curses' > "$GNUPGHOME/gpg-agent.conf"
gpgconf --kill gpg-agent
```

pinentry-curses draws in the terminal you're in, so it needs `GPG_TTY`. Add this to
`~/git/dots/config/zsh/.zshrc`, under the `PASSWORD_STORE_DIR` line, then open a new terminal:

```bash
export GPG_TTY=$(tty)
```

Don't enable Gentoo's `gpg-agent.socket` user units. They listen where the **default**
`~/.gnupg` would put its sockets, and with a custom `GNUPGHOME` gpg uses a different directory,
so they'd never be used. gpg starts the agent itself when needed.

Import the key (it asks for the key's passphrase), then trust it fully. The `.gpg-id` in the
store says which key pass encrypts to; the last line checks it matches.

```bash
[ -f ~/git/auth/gpg/private.asc ] || ~/git/auth/decrypt
gpg --import ~/git/auth/gpg/private.asc
echo "$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr/{print $10; exit}'):6:" | gpg --import-ownertrust
gpg --list-secret-keys --keyid-format long
cat "$PASSWORD_STORE_DIR/.gpg-id"
```

If the key shows `expired`, extend it (the auth README does 2 years):

```bash
gpg --quick-set-expire <key-id> 2y
gpg --quick-set-expire <key-id> 2y '*'
```

The plaintext `private.asc` isn't needed once it's imported, since `private.asc.age` stays and
`decrypt` remakes it. Delete it so the unencrypted key isn't lying around:

```bash
rm ~/git/auth/gpg/private.asc
```

**Using pass:**

| | |
|---|---|
| `pass` | tree of every entry |
| `pass show sarten` | print an entry (asks for the passphrase once; gpg-agent caches it) |
| `pass -c sarten` | copy the first line to the clipboard (`wl-copy`), cleared after 45 s |
| `pass insert email/new` | add an entry (type the password at the prompt) |
| `pass generate dev/new 32` | add an entry with a random 32-character password |
| `pass edit sarten` | open it in `$EDITOR` (nvim), re-encrypt on save |
| `pass grep -i github` | search inside the decrypted entries |

The store lives inside the `auth` repo, and `pass` notices: every `insert`, `generate`, `edit` and
`rm` makes its own commit there ("Add given password for … to store."). Only the encrypted
`.gpg` files end up in it. Pushing is up to you, and `pass git` runs git in that repo:

```bash
pass git log --oneline -3
pass git push
```

## 3. Network: iwd on its own, like NixOS

*Aspect: network*

NixOS ran iwd **without** NetworkManager (iwd does DHCP itself), plus systemd-resolved. The
quickshell bar (`netstat.sh`) and impala talk to iwd over D-Bus. Do this from a tty, because Wi-Fi
drops for a moment. NetworkManager's saved networks **don't** carry over.

`/etc/iwd/main.conf`:

```ini
[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd
[Settings]
AutoConnect=true
```

`/etc/systemd/resolved.conf.d/fallback.conf`:

```ini
[Resolve]
FallbackDNS=1.1.1.1 1.0.0.1
```

`iwctl` asks for the Wi-Fi passphrase at its prompt.

```bash
sudo systemctl disable --now NetworkManager
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl enable --now systemd-resolved iwd
iwctl station wlan0 scan; iwctl station wlan0 get-networks
iwctl station wlan0 connect "<SSID>"
ping -c2 gentoo.org
```

impala (the TUI) isn't packaged: `cargo install impala`. The §1 env already sets `CARGO_HOME`.

Now that NetworkManager is gone, run the **not used** block at the end of `packages.md`.

## 4. Kernel, lid, firewall

*Aspect: laptop (+ p1 kernelParams)*

Both kernel parameters are workarounds (`notes/structure/p1.md`):

| Param | Why |
|---|---|
| `i915.enable_psr=0` | panel self-refresh blanks the internal display |
| `video=DP-1:d` | DP-1 is a phantom (stale EDID), and Hyprland would focus it |

Add them to the end of the existing single line in `/etc/kernel/cmdline`:

```text
i915.enable_psr=0 video=DP-1:d
```

Rebuild the UKI; it takes effect at the next boot. The UKI is measured into PCR11, not PCR7, so the
TPM PIN keeps working.

```bash
sudo emerge --config sys-kernel/gentoo-kernel
```

`/etc/systemd/logind.conf.d/lid.conf`:

```ini
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
```

thermald and power-profiles-daemon were already enabled in install step 15.

**Firewall:** NixOS had one by default (nftables), and stock Gentoo has none. Only our own table
gets (re)loaded, so tailscale, mullvad and libvirt keep theirs. The ports: 41641 is tailscale,
22000/21027 syncthing, 270xx Steam remote play, server and LAN transfer.

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

## 5. Firefox: system-wide arkenfox + policies

*Aspect: firefox*

On NixOS, arkenfox's `user.cfg` plus `config/firefox/common.cfg` were loaded as autoconfig, and the
add-ons were force-installed through policies. firefox-bin lives in `/opt/firefox`. Policies and
autoconfig are system-wide, so every profile (default, study, work, infra) gets the same add-ons,
theme and prefs. **Close every Firefox window first.**

Your scripts (`browser.sh`, ALT+B) and links call plain `firefox`, but firefox-bin only installs
`firefox-bin`, and its desktop entry runs `--name=firefox-bin`, which clashes with the default
profile's remoting name `firefox`. Point `firefox` at firefox-bin and give links an entry that
runs plain `firefox`. It names the profile with `-P default`: a new Firefox install ignores
`profiles.ini`'s default and would make a fresh empty profile (that's how `default-esr` appeared).

```bash
sudo ln -sf /usr/bin/firefox-bin /usr/local/bin/firefox
mkdir -p ~/.local/share/applications
printf '[Desktop Entry]\nType=Application\nName=Firefox\nExec=firefox -P default %%u\nIcon=firefox-bin\nTerminal=false\nCategories=Network;WebBrowser;\nMimeType=application/pdf;application/xhtml+xml;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;\n' > ~/.local/share/applications/firefox.desktop
xdg-settings set default-web-browser firefox.desktop
```

The autoconfig loader:

```bash
printf '%s\n' 'pref("general.config.filename", "mozilla.cfg");' 'pref("general.config.obscure_value", 0);' \
  | sudo tee /opt/firefox/defaults/pref/autoconfig.js
```

`mozilla.cfg` is a comment line, then arkenfox (with `user_pref` → `defaultPref`), then
`common.cfg`. Rerun these two commands to update arkenfox. Gentoo upgrades leave files the package
doesn't own alone.

```bash
curl -fsSL https://raw.githubusercontent.com/arkenfox/user.js/master/user.js \
  | sed 's/^user_pref(/defaultPref(/' > /tmp/arkenfox.cfg
{ echo '// p1 autoconfig'; cat /tmp/arkenfox.cfg ~/git/dots/config/firefox/common.cfg; } \
  | sudo tee /opt/firefox/mozilla.cfg >/dev/null
```

Policies: every Firefox on Linux reads `/etc/firefox/policies/policies.json`. The add-on list
(and the theme, which is one of them) lives in `scripts/firefox/policies.sh` in dots. To add or
remove an add-on, edit its `ADDONS` array, then run it again. It shows the change first; `--apply`
writes it (sudo). It also warns if the theme `common.cfg` picks isn't in the list.

```bash
~/git/dots/scripts/firefox/policies.sh
~/git/dots/scripts/firefox/policies.sh --apply
```

The theme comes from `extensions.activeThemeID` in `common.cfg`, which is only a default: a
profile that ever saved its own theme keeps it. Clear that once per profile:

```bash
for p in default study work infra; do sed -i '/"extensions.activeThemeID"/d' ~/.config/mozilla/firefox/$p/prefs.js; done
```

Check `about:policies` (Active) and `general.config.filename` in `about:config`. The add-ons
download from addons.mozilla.org on each profile's first start. The profiles
(default, study, work, infra) come from `scripts/firefox/setup.sh`, which `home_setup.sh` runs (§1.8).

dejsonlz4 isn't packaged. You'd only need it to read sessionstore files by hand.

## 6. Hardware

*Aspects: audio, bluetooth, controller, hhkb, colord, android, intel-gpu, nvidia-prime, fingerprint, tpm*

**Packages:** `packages.md` → **hardware**

- dualsensectl isn't packaged. xpadneo is a kernel module, signed by modules-sign.
- The audio aspect also had JACK. If you use JACK apps:
  `echo 'media-video/pipewire jack-sdk' | sudo tee -a /etc/portage/package.use/p1`

**HHKB:** the ◇ keys send Muhenkan/Henkan, and keyd turns them into meta, for `04fe:0021` only.
`/etc/keyd/hhkb.conf`:

```ini
[ids]
04fe:0021

[main]
muhenkan = leftmeta
henkan = rightmeta
```

```bash
sudo systemctl enable --now keyd colord bluetooth
```

To power bluetooth on at boot (NixOS's `powerOnBoot`), set `AutoEnable=true` under `[Policy]` in
`/etc/bluetooth/main.conf`.

Groups the aspects gave admins, with their Gentoo names: `tss` (tpm), `kvm` (android/libvirt),
`pcap` (wireshark, §11), `libvirt` (§9). audio, video, input, render and wheel were done in the
install. They take effect at the next login.

```bash
sudo usermod -aG tss,kvm meow
```

NixOS's `nvidia-offload` is `prime-run` here. ES-DE's wrapper calls it by name:

```bash
sudo ln -s /usr/bin/prime-run /usr/local/bin/nvidia-offload
```

- NPU (`intel-npu.nix`): the kernel driver `ivpu` is in gentoo-kernel. Add userspace only if you
  use it.

### nvidia

nvidia uses the open kernel module by default now. Power management for the dGPU, in
`/etc/modprobe.d/nvidia-pm.conf`:

```text
options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1
```

Enable `nvidia-powerd` and rebuild the UKI so it picks up the modprobe options:

```bash
sudo systemctl enable nvidia-powerd
sudo emerge --config sys-kernel/gentoo-kernel
```

`nvidia-suspend`, `nvidia-resume` and `nvidia-hibernate` no longer exist (595.x): the driver
handles suspend itself (`UseKernelSuspendNotifiers=1`). Check after the next reboot:

```bash
grep -E 'DynamicPower|PreserveVideo|SuspendNotif' /proc/driver/nvidia/params   # 2 / 1 / 1
```

Hyprland runs on the Intel Arc. Use `prime-run <app>` for the RTX, and check it with
`prime-run nvidia-smi`.

### Firmware updates (fwupd)

fwupd with Secure Boot on your own keys. Add this to `/etc/fwupd/fwupd.conf` with `sudoedit`.
This file doesn't allow comments on the same line as a value.
- `EspLocation`: there's no udisks2, and without this you get "UEFI ESP partition not detected".
- `DisableShimForSecureBoot`: there's no shim here, and `fwupdx64.efi.signed` is signed with the
  sbctl db key.

```ini
[uefi_capsule]
EspLocation=/efi
DisableShimForSecureBoot=true
```

`get-updates` covers the Goodix sensor and BIOS firmware. The `sbverify` issuer should be
`CN=Database Key`.

```bash
sudo systemctl restart fwupd
sbverify --list /usr/libexec/fwupd/efi/fwupdx64.efi.signed
sudo fwupdmgr refresh && sudo fwupdmgr get-updates
```

Plug in AC power, then run `sudo fwupdmgr update`. It reboots and flashes; it may reboot twice,
so don't power off. BIOS and Microsoft db (2023 CA) updates change PCR7, so the PIN fails once:
use the passphrase, then re-enroll (install step 18).
Done 2026-10-01: BIOS 0.1.20 → 0.1.21 (N48ET34W), UEFI CA db 2011 → 2023.

### Fingerprint

| | |
|---|---|
| Disk unlock | TPM PIN |
| tty1 | logs in automatically |
| sudo | NOPASSWD, so fprintd is never asked |
| Fingerprint | hyprlock (lock screen) |

NixOS also used it for login and sudo. Enroll as meow, **without** sudo:

```bash
fprintd-enroll                     # right index finger
fprintd-enroll -f left-index-finger
fprintd-verify
```

hyprlock, in `~/.config/hypr/hyprlock.conf` (it's your dots file, so check it first):

```text
auth {
    fingerprint:enabled = true
}
```

Optional, for the other ttys: add `auth sufficient pam_fprintd.so` as the first auth line of
`/etc/pam.d/login`. If sudo ever asks for a password again, the same line as the first auth line
of `/etc/pam.d/sudo` makes it accept a finger. Keep a root shell open (`sudo -i` in another tty)
while editing PAM.

## 7. Rest of the dotfile changes (in `~/git/dots`)

These paths only exist on NixOS. Edit, test, commit: dots is now a Gentoo repo for p1. The two
`hyprland.lua` fixes were done in §1.7.

| File | Change |
|---|---|
| `config/ES-DE/custom_systems/es_find_rules.xml:7` | `/run/current-system/sw/lib/retroarch/cores` → wherever RetroArch's cores end up (§12) |
| `config/yazi/theme.toml:109` | `syntect_theme` is a `/nix/store` path → copy the `.tmTheme` into `config/yazi` |
| `config/bash/bashrc:81` | `alias rebuild='doas nixos-rebuild switch'` → delete |
| `config/zsh/.zsh_functions` | `nix-clean`, `nix-roots` → delete (or rewrite around `emerge --depclean`) |
| `scripts/firefox/{setup,forget}.sh` | `pgrep -f 'lib/firefox/firefox'` never matches firefox-bin (`/opt/firefox/firefox`): `sed -i "s\|pgrep -f 'lib/firefox/firefox'\|pgrep -f '/firefox/firefox'\|" ~/git/dots/scripts/firefox/{setup,forget}.sh` |
| `nix/`, `flake.*`, `secrets/`, `.sops.yaml`, `auth.nix` | keep for reference or delete; nothing on p1 reads them now |
| `CLAUDE.md` | "Applying changes" / "Rebuilding" are NixOS; it also says the repo has no docs besides itself and README, and `gentoo/` breaks that |
| `README.md` | device table: Thinkpad P1 Gen 7, Gentoo |

## 8. Dev

*Aspects: git, neovim, python, javascript, database, database-gui, dbt, infra, vscodium, web-dev, work, cli (direnv)*

**Packages:** `packages.md` → **dev**. Its **before** block sets `rust-bin[rust-analyzer]`.

```bash
git lfs install
```

These aren't packaged, so install them as your user. They land in `~/.local/bin` (§1 env):

```bash
npm i -g @fsouza/prettierd eslint_d
go install mvdan.cc/sh/v3/cmd/shfmt@latest
go install github.com/xo/usql@latest
uv tool install harlequin; uv tool install sqlfluff
uv tool install dbt-core --with dbt-postgres
```

The python aspect (numpy, pandas, polars, pyarrow, scipy, scikit-learn, matplotlib, seaborn, plotly,
jupyterlab, ipython, sqlalchemy, openpyxl, requests, httpx, black, isort, mypy, mutagen): polars
isn't in ::gentoo, and pip into the system Python is blocked (PEP 668). So, one venv:

```bash
uv venv ~/.local/share/py && VIRTUAL_ENV=~/.local/share/py uv pip install \
  numpy pandas polars pyarrow scipy scikit-learn matplotlib seaborn plotly jupyterlab ipython \
  sqlalchemy openpyxl requests httpx black isort mypy mutagen
```

Use it with `source ~/.local/share/py/bin/activate`, or `uv run --python ~/.local/share/py/bin/python`.
nix-direnv was Nix-only, so it's plain direnv (`config/direnv`); for Python projects, use
`layout uv` or venvs.

VSCodium extensions (Open VSX IDs, same list as `dev/tools.nix`).
`ms-vscode-remote.remote-ssh` isn't on Open VSX; `open-remote-ssh` replaces it.

```bash
for e in anthropic.claude-code asvetliakov.vscode-neovim bbenoist.nix enkia.tokyo-night \
  mechatroner.rainbow-csv ms-azuretools.vscode-docker ms-python.python \
  jeanp413.open-remote-ssh shd101wyy.markdown-preview-enhanced yzhang.markdown-all-in-one \
  zhuangtongfa.material-theme; do codium --install-extension "$e"; done
```

The work aspect's cursor and postman aren't packaged. Use Flatpak (§13) or the upstream AppImage.

**postgres-local:** PostgreSQL 17 (in the dev block), with a database `play` owned by meow,
trusted on loopback only.

```bash
sudo emerge --config dev-db/postgresql:17
```

Replace the rules in `/etc/postgresql-17/pg_hba.conf` with:

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

**Packages:** `packages.md` → **virt**. Its **before** block has the qemu/libvirt USE flags.

NixOS also had a oneshot that stopped libvirt networks from autostarting. Do that once by hand
(the `for` line). Download the virtio-win ISO from fedorapeople when a Windows guest needs it.

```bash
echo 'options kvm_intel nested=1' | sudo tee /etc/modprobe.d/kvm.conf
sudo usermod -aG libvirt meow
sudo systemctl enable --now libvirtd
for n in $(sudo virsh net-list --all --name); do sudo virsh net-autostart --disable "$n"; done
```

## 10. Network services

*Aspects: tailscale, mullvad, mullvad-tailscale, syncthing, wazuh-syslog, net-tools, soc-tools*

**Packages:** `packages.md` → **net**

Tailscale runs on nftables and never waits for network-online. `systemctl edit tailscaled` opens an
editor: add `Environment=TS_DEBUG_FIREWALL_MODE=nftables` under `[Service]`. The Mullvad GUI is
`mullvad-vpn`, and `hyprland.lua` autostarts it.

```bash
sudo systemctl edit tailscaled
sudo systemctl enable --now tailscaled && sudo tailscale up
sudo systemctl enable --now mullvad-daemon
```

Mullvad takes the default route and swallows the tailnet. This table marks tailnet traffic so it
bypasses the tunnel. **The hook priorities matter** (dots `CLAUDE.md`, `net/vpn.nix`). Add it to
`/etc/nftables.d/p1.nft` (the same file as §4, its own table):

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
```

**Syncthing:** NixOS ran it as a system user whose state got wiped every boot (it wasn't
persisted). Here it's **your** user service, with its config and state in
`~/.local/state/syncthing` and the GUI at `127.0.0.1:8384`.

```bash
systemctl --user enable --now syncthing.service
```

**wazuh-syslog:** forward everything from the journal to the manager over UDP.
`/etc/rsyslog.d/90-wazuh.conf`:

```text
module(load="imjournal" StateFile="imjournal.state")
*.* action(type="omfwd" target="192.168.1.142" port="514" protocol="udp" template="RSYSLOG_TraditionalForwardFormat")
```

```bash
sudo systemctl enable --now rsyslog
```

## 11. Pentest (optional, big)

*Aspect: pentest*

**Packages:** `packages.md` → **pentest**

The `pcap` group lets Wireshark capture without root:

```bash
sudo usermod -aG pcap meow
```

These aren't in ::gentoo or ::guru, so use go/uv/cargo as needed. Don't enable the whole ::pentoo
overlay, because it overrides system packages.

```bash
go install github.com/ffuf/ffuf/v2@latest
go install github.com/OJ/gobuster/v3@latest
go install github.com/projectdiscovery/{nuclei/v3/cmd/nuclei,subfinder/v2/cmd/subfinder,katana/cmd/katana}@latest
go install github.com/owasp-amass/amass/v4/...@master
go install github.com/jpillora/chisel@latest
cargo install feroxbuster
uv tool install netexec; uv tool install dnsrecon
```

Install these when you actually need them: burpsuite (PortSwigger installer), metasploit (upstream
omnibus), seclists (git clone into `~/archive`), exploitdb, wpscan (gem), bettercap, responder,
smbmap, enum4linux-ng, whatweb, cewl, hashid, ligolo-ng, social-engineer-toolkit.

## 12. Games

*Aspects: steam, wine, lutris, osu-lazer, stepmania, star-citizen, emulators, uzdoom*

**Packages:** `packages.md` → **games**. Its **before** block:
- pins wine-staging to 11.14 (11.16 breaks MusicBee)
- sets `wow64`, so Wine needs no 32-bit multilib
- enables steam-overlay

```bash
sudo eselect wine set wine-staging-11.14 2>/dev/null || true
```

- **Steam** (native, like `programs.steam`) is in the games block. Its 32-bit dependencies ask for
  a long autounmask list: `--autounmask-write`, `dispatch-conf`, rerun. A lighter option is the
  Flatpak, `com.valvesoftware.Steam`.
- **Packaged emulators:** dolphin, pcsx2, ppsspp, azahar, rpcs3, eden. All are in the games block.
- **Not packaged**, use Flatpak: RetroArch (`org.libretro.RetroArch`, cores from its updater),
  Cemu (`info.cemu.Cemu`), Ryubing, ITGmania/StepMania.
- **Upstream AppImage** into `~/.local/bin`: Xenia-canary and ES-DE. The es-de wrapper is in
  `emulation.nix` (`ESDE_APPDATA_DIR` + `nvidia-offload`). Then fix ES-DE's find rules for those
  paths (§7).
- **Star Citizen:** nix-citizen isn't available, so use Lutris' "RSI Launcher" installer.
- **BIOS links:** `home_setup.sh` makes them once `~/archive/roms/bios` exists.

## 13. Apps + CLI

*Aspects: flatpak, gimp, kiwix, monero, qbittorrent, irc, music, tectonic, typst, atuin, cli*

**Packages:** `packages.md` → **apps** (includes flatpak), then **cli**

```bash
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

## 14. Shared account (kazu)

*auth.nix `shared` (uid 1001, group `share`) + share.nix bind mounts*

These are bind mounts, not symlinks: a symlink would need traverse permission on `/home/meow`
(dots `CLAUDE.md`, "Sharing a directory").

```bash
sudo groupadd share && sudo usermod -aG share meow
sudo useradd -m -u 1001 -G share -s /bin/zsh shared && sudo passwd -l shared
sudo install -d -m700 -o shared -g shared /home/shared/.ssh
```

`/home/shared/.ssh/authorized_keys` gets the two kazu keys from auth.nix (owner `shared`, mode
600).

Append to `/etc/fstab`. With `nofail`, a missing source never blocks boot.

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

Make them writable for the share group (the tmpfiles `A+` rule on NixOS). This sets ACLs on the
files already in `~/archive`. `games/` has about 300k files, so it's slow.

```bash
for d in media/anime arcade media/book games media/movies media/music roms media/series media/youtube; do
  setfacl -R -m g:share:rwX -m d:g:share:rwX ~/archive/$d; done
```

## 15. Not coming over

| NixOS | Here |
|---|---|
| impermanence (wipe `/` on boot) | btrfs `@` + `@snapshots` instead; snapper later if wanted |
| sops-nix for passwords | passwords live in `/etc/shadow`; sops/age stay for `~/git/auth` |
| nh, cachix, nix-direnv, star-citizen-cache, flannel overlay | Nix only |
| hermes (NousResearch hermes-agent service) | no package. Later, if wanted: `uv tool install` from its repo, token from `sops -d ~/git/dots/secrets/secrets.yaml` (key `hermes/…`) into an env file, then a user service |
| `services.getty.autologinOnce` | systemd has no "once"; tty1 autologins every time |
| sudo timestamp/lecture settings | moot, sudo is NOPASSWD |

## 16. Check

`emerge -pv @world` should have nothing pending. The last command is the check from `packages.md`,
and it should print nothing.

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

## 17. Last: switch to bleeding edge (~amd64), then Graphite / LTO / PGO

The goal for this system is the newest versions, built as fast as the hardware allows. This is
the **last** step on purpose. Install and setup run on stable, where most packages come prebuilt,
so the desktop is usable quickly. Then this switch rebuilds most of the system from source while
you keep working in Hyprland and Firefox.

### Testing branch (`~amd64`)

Every package gets its newest Gentoo version (usually days after release, not months). The
per-package `~amd64` lines from `packages.md` become redundant (harmless; delete them if you
like).

What it costs:
- **More compiling.** Gentoo's binhost mostly has stable versions, so most packages build from
  source. The `-bin` packages (firefox-bin, signal-desktop-bin, …) stay prebuilt.
- **Occasional breakage.** Testing is what Gentoo developers run day to day. It's usually fine,
  but sometimes an update needs a manual fix. The previous kernel stays in the systemd-boot
  menu until `depclean`, so a bad kernel is one reboot away from fixed.

**Switching.** Dry run on 2026-10-01 (after §1-§4): 265 packages, 258 from source, among them
kernel 6.18 → 7.2.8, glibc 2.44, systemd 262, Mesa 26.2, nvidia 615, LLVM 23, and a Hyprland
rebuild. Many hours. Skim `eselect news list` first. The new kernel
builds a new UKI, so `linux-firmware` and `intel-microcode` must be installed (base block).

1. In `/etc/portage/make.conf`, add `ACCEPT_KEYWORDS="~amd64"`. If `networkmanager` is still in
   `USE`, take it out (§3 replaced it with iwd).
2. Make sure the **desktop: apps** "before" block has been run (libxmlb for nemo). Then give gcc
   its flags: it gets rebuilt in this upgrade anyway, so it's built with LTO + PGO once (a faster
   compiler) and gains Graphite for later.

```bash
echo 'sys-devel/gcc graphite lto pgo' | sudo tee -a /etc/portage/package.use/p1
sudo emerge --deselect www-client/firefox
```

Deselecting the old source `www-client/firefox` matters: left in @world, it compiles Firefox
from source (hours on its own). firefox-bin is the one in use.

3. Run the upgrade on **tty2 inside tmux**, not in a Hyprland terminal: a terminal inside the
   session dies with it. CTRL+ALT+F2, log in, then:

```bash
tmux new -s world
sudo emerge -avuDN --backtrack=50 --keep-going @world
```

Go back to Hyprland with CTRL+ALT+F1 and keep working. Watch it from ghostty with
`tmux attach -t world` (detach: prefix, then `d`). `--backtrack=50` lets portage work out that
ghostty needs a rebuild for the new glslang (without it: a glslang slot conflict), and
`--keep-going` stops one failed package from stopping the rest.

4. When it's done: Hyprland was rebuilt, so rebuild hyprglass (§1.6), then clean up and reboot:

```bash
make -C ~/.cache/hyprglass clean
make -C ~/.cache/hyprglass CXX=g++ INCLUDES="$(pkg-config --cflags hyprland pixman-1 libdrm lua5.4)"
sudo install -Dm755 ~/.cache/hyprglass/hyprglass.so /usr/local/lib/libhyprglass.so
sudo emerge -a --depclean
sudo reboot
uname -r                      # 7.2.x
lsmod | grep nvidia           # signed modules load under Secure Boot
```

### Later: Graphite, LTO, PGO

gcc is already built with `graphite lto pgo`. That makes gcc itself faster, and gives it
Graphite's loop optimizer. Turning the optimizations on for everything else is a separate
step, and worth doing only once `~amd64` has run without trouble for a while. In order:

1. **PGO and LTO where packages offer them.** Add `lto pgo` to the global `USE`. Packages with
   those flags (python, clang/llvm, gcc and others) build that way. firefox-bin stays prebuilt;
   a PGO+LTO Firefox means switching to source `www-client/firefox` with `USE="lto pgo"`, which is
   a long build.
2. **LTO for everything.** Add `-flto=auto` to `COMMON_FLAGS`. Some packages break with it, so
   they go in a `package.env` exception list as they come up (the Gentoo wiki's LTO page
   tracks known ones). Rebuild with `emerge -e @world`.
3. **Graphite.** Add `-fgraphite-identity -floop-nest-optimize` to `COMMON_FLAGS`. The gains are
   usually small and package-dependent, with more breakage, so this goes last.

Once custom `CFLAGS` are in, the binhost works against you: its packages are built with the
default flags, and portage installs them regardless of yours. For a system built entirely with
your flags, take `getbinpkg` out of `FEATURES`.

**Maintenance:** after kernel updates, `sudo emerge --depclean` removes old gentoo-kernel versions
and their UKIs (`ls /efi/EFI/Linux/`). After a BIOS or Secure Boot change, re-enroll the TPM
(install step 18).
