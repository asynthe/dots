# p1 packages

Every package p1 has on purpose, one code block per group. Copy a block, paste it, read the
`-a` list, say yes. `--noreplace` means a package that's already there is only recorded in
@world, never rebuilt, so any block is safe to re-run.

Adding a package: put its line in the right block **here first**, then run the block.
Removing one: delete its line, `sudo emerge --deselect <atom>`, then `sudo emerge -a --depclean`.

Blocks with a **before** block need those lines once (keywords, USE flags, masks). They're
already in `/etc/portage` if you've run them before; re-running just overwrites the same file.

The system is installed and set up on **stable**, so packages that only exist in testing need the
`~amd64` lines in their **before** block. `setup.md` §17 switches everything to `~amd64` at the
end; after that those lines are redundant but harmless. Live `9999` ebuilds always need `**`.

Status 2026-10-01: base and desktop are installed. desktop was checked with a plain `emerge -p`.
The other blocks haven't been run yet, so expect a keyword or USE prompt on the first run.

---

## base

From install.md steps 9-15. `linux-firmware` and `intel-microcode` go in **after** the kernel
(their postinst rebuilds the UKI).

```bash
sudo emerge -av --noreplace \
  sys-kernel/gentoo-kernel \
  sys-kernel/linux-firmware \
  sys-firmware/intel-microcode \
  sys-firmware/sof-firmware \
  sys-fs/btrfs-progs \
  sys-fs/mdadm \
  sys-fs/cryptsetup \
  sys-fs/dosfstools \
  app-crypt/tpm2-tss \
  app-crypt/tpm2-tools \
  app-crypt/sbctl \
  app-crypt/sbsigntools \
  sys-boot/efibootmgr \
  sys-apps/nvme-cli \
  sys-apps/zram-generator \
  sys-apps/fwupd \
  sys-power/thermald \
  sys-power/power-profiles-daemon \
  sys-power/upower \
  sys-power/acpi \
  net-wireless/iwd \
  net-wireless/bluez \
  net-firewall/nftables \
  app-shells/zsh \
  app-admin/sudo \
  app-editors/neovim \
  dev-vcs/git \
  net-misc/rsync \
  app-eselect/eselect-repository
```

## desktop: session

Hyprland and its pieces. The bar and wallpaper picker are **quickshell**, the wallpaper daemon
is **awww**, and the session starts from tty1 autologin via **uwsm**. Not used: waybar,
waypaper, greetd, tuigreet.

before:
```bash
echo '*/*::hyproverlay ~amd64' | sudo tee /etc/portage/package.accept_keywords/hyproverlay
echo 'dev-cpp/sdbus-c++ ~amd64' | sudo tee /etc/portage/package.accept_keywords/sdbus-c++
echo 'gui-apps/uwsm ~amd64' | sudo tee /etc/portage/package.accept_keywords/uwsm
echo 'gui-apps/quickshell -crash-handler -networkmanager' | sudo tee /etc/portage/package.use/quickshell
```

```bash
sudo emerge -av --noreplace \
  gui-wm/hyprland \
  gui-apps/uwsm \
  sys-auth/hyprpolkitagent \
  gui-apps/hypridle \
  gui-apps/hyprlock \
  gui-libs/xdg-desktop-portal-hyprland \
  gui-apps/quickshell \
  dev-qt/qtdeclarative \
  gui-apps/awww \
  gui-apps/mako \
  x11-libs/libnotify \
  gui-apps/fuzzel \
  x11-misc/rofi \
  gui-apps/walker \
  gui-apps/hyprshot \
  x11-misc/gromit-mpx \
  gui-apps/wl-clipboard \
  media-sound/playerctl \
  app-misc/brightnessctl \
  net-misc/socat \
  x11-themes/adw-gtk3 \
  x11-misc/xdg-user-dirs \
  gnome-base/dconf \
  x11-drivers/nvidia-drivers \
  x11-misc/prime-run \
  media-libs/libva-intel-media-driver \
  media-video/pipewire \
  media-video/wireplumber \
  sys-auth/fprintd
```

## desktop: apps

Apps that don't need Hyprland. **ghostty** is the main terminal, **yazi** the terminal file manager
(nemo is the GUI one), and **kitty** stays as
the fallback because Hyprland's default config uses it. Firefox is **firefox-bin**, not the
source-built `www-client/firefox`.

before (the libxmlb line is for nemo once on ~amd64; harmless before):
```bash
echo 'x11-terms/wezterm ~amd64' | sudo tee /etc/portage/package.accept_keywords/wezterm
echo 'dev-libs/libxmlb introspection' | sudo tee /etc/portage/package.use/nemo
```

```bash
sudo emerge -av --noreplace \
  x11-terms/ghostty \
  x11-terms/kitty \
  x11-terms/alacritty \
  x11-terms/wezterm \
  www-client/firefox-bin \
  media-gfx/imv \
  media-video/mpv \
  app-misc/yazi \
  gnome-extra/nemo \
  gnome-base/gvfs \
  xfce-base/tumbler \
  media-sound/pavucontrol \
  net-im/signal-desktop-bin \
  net-im/vesktop-bin \
  app-text/zathura \
  app-text/poppler
```

Not in Portage, so install these by hand:
- **ungoogled-chromium**: `flatpak install --user flathub io.github.ungoogled_software.ungoogled_chromium`
  (`www-client/chromium` is being removed from ::gentoo on 2026-10-24)
- **sioyek**: only a live `9999` ebuild exists. If you want it anyway:
  `echo 'app-text/sioyek **' | sudo tee /etc/portage/package.accept_keywords/sioyek`
- warp-terminal, ripdrag (`cargo install ripdrag`), xdg-ninja (git clone)

## fonts

before:
```bash
echo 'media-fonts/nerdfonts firacode iosevkaterm iosevkatermslab jetbrainsmono mononoki overpass sourcecodepro ubuntusans zedmono' | sudo tee /etc/portage/package.use/fonts
echo 'app-i18n/mozc fcitx5' | sudo tee -a /etc/portage/package.use/fonts
echo 'media-fonts/office-code-pro ~amd64' | sudo tee /etc/portage/package.accept_keywords/fonts
```

Checked 2026-10-01 on stable with a plain `emerge -p`: resolves, 32 packages, 11 from source
(mozc is the long one).

```bash
sudo emerge -av --noreplace \
  media-fonts/nerdfonts \
  media-fonts/noto \
  media-fonts/noto-cjk \
  media-fonts/noto-emoji \
  media-fonts/corefonts \
  media-fonts/dejavu \
  media-fonts/liberation-fonts \
  media-fonts/office-code-pro \
  media-fonts/source-sans \
  media-fonts/fontawesome \
  media-gfx/fontpreview \
  media-gfx/gnome-font-viewer \
  gnome-extra/gucharmap \
  x11-themes/adwaita-icon-theme \
  app-i18n/fcitx \
  app-i18n/fcitx-gtk \
  app-i18n/fcitx-qt \
  app-i18n/fcitx-configtool \
  app-i18n/mozc
```

Not packaged: **TX-02** and **Smash** come from `~/git/dots/assets/fonts` (setup.md §1.4).
et-book and garamond-libre: download them into `~/.local/share/fonts`.

## hardware

before:
```bash
printf '%s ~amd64\n' media-sound/wiremix net-wireless/bluez-tools x11-apps/igt-gpu-tools app-mobilephone/scrcpy app-crypt/tpm2-pkcs11 dev-python/python-pkcs11 dev-python/tpm2-pytss | sudo tee /etc/portage/package.accept_keywords/hardware
```

Checked 2026-10-01 on stable with a plain `emerge -p`: resolves, 68 packages, 25 from source.
`python-pkcs11` and `tpm2-pytss` are dependencies of `tpm2-pkcs11`. Mixers: `alsamixer` comes from
`alsa-utils`, `wiremix` (PipeWire TUI) and `pulsemixer` are their own packages.

```bash
sudo emerge -av --noreplace \
  media-sound/alsa-utils \
  media-sound/pulsemixer \
  media-sound/wiremix \
  sys-auth/rtkit \
  net-wireless/blueman \
  net-wireless/bluetuith \
  net-wireless/bluez-tools \
  games-util/xpadneo \
  app-misc/keyd \
  x11-misc/colord \
  dev-util/android-tools \
  app-mobilephone/scrcpy \
  dev-libs/intel-compute-runtime \
  x11-apps/igt-gpu-tools \
  media-video/libva-utils \
  sys-process/nvtop \
  x11-apps/mesa-progs \
  app-crypt/tpm2-pkcs11
```

Not packaged: dualsensectl.

## cli

Everything from NixOS's `cli.nix`. `psmisc` provides `killall`.

```bash
sudo emerge -av --noreplace \
  sys-apps/bat \
  sys-devel/bc \
  media-gfx/chafa \
  media-libs/exiftool \
  sys-apps/eza \
  sys-apps/fd \
  sys-apps/ripgrep \
  media-video/ffmpeg \
  media-video/ffmpegthumbnailer \
  app-shells/fzf \
  app-misc/skim \
  sys-process/htop \
  sys-process/btop \
  app-benchmarks/hyperfine \
  media-gfx/imagemagick \
  sys-apps/inxi \
  app-misc/jq \
  sys-process/psmisc \
  sci-libs/libqalculate \
  sys-process/lsof \
  media-video/mediainfo \
  sys-fs/ncdu \
  mail-client/neomutt \
  sys-fs/ntfs3g \
  sys-apps/pciutils \
  sys-apps/pv \
  sys-apps/smartmontools \
  media-sound/sox \
  app-shells/starship \
  app-misc/superfile \
  app-misc/tmux \
  app-misc/tmuxp \
  app-text/tree \
  app-arch/unzip \
  app-arch/unar \
  app-arch/rar \
  app-editors/vim \
  app-editors/helix \
  net-misc/wget \
  app-misc/lf \
  net-misc/yt-dlp \
  app-shells/zoxide \
  app-shells/atuin \
  app-crypt/age \
  app-crypt/sops \
  app-admin/pass \
  app-misc/fastfetch \
  app-misc/pfetch \
  app-misc/figlet \
  games-misc/lolcat \
  app-misc/pipes-rs \
  app-misc/tty-clock \
  dev-perl/Term-Animation
```

zsh's idle screensaver (`.zshrc`, after 180 s) runs one of `unimatrix`, `pipes-rs` and `asciiquarium`
at random. pipes-rs is packaged. The other two are single scripts in `~/.local/bin`:
- **asciiquarium**: the transparent fork, because `.zshrc` uses `-t -s`, which GURU's original
  1.1 doesn't have. `Term-Animation` above is its Perl library.
- **unimatrix**: a Python script.

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/nothub/asciiquarium/master/asciiquarium -o ~/.local/bin/asciiquarium
curl -fsSL https://raw.githubusercontent.com/will8211/unimatrix/master/unimatrix.py -o ~/.local/bin/unimatrix
chmod +x ~/.local/bin/asciiquarium ~/.local/bin/unimatrix
```

Not packaged: impala (`cargo install impala`), starfetch, peaclock, tenki, clock-rs. Rust tools: use
Portage when it has them, `cargo install` otherwise (`cargo install-update -a` updates those).

## net

```bash
sudo emerge -av --noreplace \
  net-analyzer/macchanger \
  net-vpn/tailscale \
  net-vpn/mullvadvpn-app \
  net-p2p/syncthing \
  app-admin/rsyslog \
  net-analyzer/bandwhich \
  net-analyzer/nethogs \
  net-analyzer/speedtest-cli \
  net-analyzer/hping \
  sys-apps/net-tools \
  net-analyzer/nmap \
  net-analyzer/tcpdump \
  app-forensics/foremost
```

## dev

before:
```bash
echo 'dev-lang/rust-bin rust-analyzer rust-src' | sudo tee /etc/portage/package.use/rust
```

```bash
sudo emerge -av --noreplace \
  dev-vcs/git-lfs \
  dev-vcs/bfg \
  dev-vcs/jj \
  net-libs/nodejs \
  sys-apps/yarn \
  dev-lang/typescript \
  dev-lang/go \
  dev-lang/rust-bin \
  dev-python/uv \
  app-shells/direnv \
  dev-util/bash-language-server \
  dev-python/pyright \
  dev-util/typescript-language-server \
  dev-util/marksman \
  dev-util/lua-language-server \
  dev-go/gopls \
  dev-util/vscode-langservers-extracted \
  dev-util/yaml-language-server \
  dev-util/tree-sitter-cli \
  dev-util/stylua \
  dev-util/ruff \
  dev-db/duckdb \
  dev-db/sqlite \
  dev-db/pgcli \
  dev-db/litecli \
  dev-db/dbeaver-bin \
  dev-db/postgresql:17 \
  app-admin/opentofu \
  app-admin/ansible \
  app-admin/ansible-lint \
  app-editors/vscodium \
  dev-util/bruno-bin \
  www-apps/hugo \
  app-arch/7zip \
  dev-util/claude-code \
  dev-util/codex \
  dev-util/opencode-bin
```

Not in Portage, so install these as your user (setup.md §8): prettierd and eslint_d (npm),
shfmt and usql (go), harlequin, sqlfluff and dbt (uv tool), and the Python data stack (one uv venv).

## virt

before:
```bash
echo 'app-emulation/qemu spice usbredir usb virtfs' | sudo tee /etc/portage/package.use/virt
echo 'app-emulation/libvirt virt-network qemu virtiofsd' | sudo tee -a /etc/portage/package.use/virt
```

```bash
sudo emerge -av --noreplace \
  app-emulation/libvirt \
  app-emulation/virt-manager \
  app-emulation/qemu \
  app-crypt/swtpm \
  net-misc/spice-gtk \
  app-emulation/spice-vdagent \
  app-emulation/virtiofsd \
  app-emulation/libguestfs \
  app-emulation/guestfs-tools \
  net-dns/dnsmasq
```

## apps

```bash
sudo emerge -av --noreplace \
  sys-apps/flatpak \
  media-gfx/gimp \
  www-misc/kiwix-desktop \
  net-p2p/monero \
  net-p2p/qbittorrent \
  net-irc/irssi \
  net-irc/weechat \
  media-sound/cava \
  media-sound/cmus \
  media-sound/mixxx \
  media-sound/mpd \
  media-sound/ncmpcpp \
  media-sound/rmpc \
  media-sound/spek \
  dev-tex/tectonic \
  app-text/typst
```

Not packaged: monero-gui, cliamp.

## games

wine-staging is pinned to **11.14**, because 11.16 breaks MusicBee. `wow64` means Wine
doesn't need 32-bit multilib. Steam needs the steam-overlay repo, and its 32-bit dependencies
will ask for a long autounmask list (`--autounmask-write`, then `dispatch-conf`, then run it again).

Status 2026-10-01: the three wine lines of **before** are applied and wine-staging + winetricks are
installed (34 packages, 26 binaries). The rest of the block and steam-overlay are not run yet.
`wine` is in `/etc/eselect/wine/bin`, which a shell only gets after `. /etc/profile` or a re-login.

before:
```bash
echo '>app-emulation/wine-staging-11.14' | sudo tee /etc/portage/package.mask/wine
echo '=app-emulation/wine-staging-11.14 ~amd64' | sudo tee /etc/portage/package.accept_keywords/wine
echo 'app-emulation/wine-staging wow64 wayland' | sudo tee /etc/portage/package.use/wine
sudo eselect repository enable steam-overlay && sudo emaint sync -r steam-overlay
```

```bash
sudo emerge -av --noreplace --backtrack=50 --usepkg-exclude net-libs/webkit-gtk \
  app-emulation/wine-staging \
  app-emulation/winetricks \
  dev-lang/mono \
  games-util/lutris \
  games-util/gamemode \
  app-emulation/protontricks \
  games-util/protonup-rs \
  games-util/steam-launcher \
  games-arcade/osu-lazer \
  games-engines/uzdoom \
  games-emulation/dolphin \
  games-emulation/pcsx2 \
  games-emulation/ppsspp \
  games-emulation/azahar \
  games-emulation/rpcs3 \
  games-emulation/eden
```

Checked 2026-10-02 on `~amd64`. Steam's 32-bit libraries hit two snags, both handled above:
- **gpm ↔ ncurses loop:** run `sudo USE="-gpm" emerge -av1 sys-libs/ncurses` once before the
  block, then `sudo emerge -avuDN @world` after it, to put `gpm` back.
- **libavif slot conflict:** the binhost's webkit-gtk (for Lutris) is built against an older
  libavif, so `--usepkg-exclude` makes it compile from source (over an hour).
- Autounmask writes the `abi_x86_32` lines Steam needs into `package.use`; that's expected.

Not in Portage:
- **Flatpak:** RetroArch (`org.libretro.RetroArch`), Cemu (`info.cemu.Cemu`), Ryubing, ITGmania
- **AppImage:** ES-DE, Xenia-canary
- **Lutris installer:** Star Citizen (RSI Launcher)

## pentest (optional)

```bash
sudo emerge -av --noreplace \
  net-analyzer/wireshark \
  net-analyzer/masscan \
  net-analyzer/rustscan \
  net-analyzer/arp-scan \
  net-analyzer/nikto \
  dev-db/sqlmap \
  net-analyzer/sslscan \
  net-analyzer/testssl \
  net-proxy/mitmproxy \
  net-analyzer/termshark \
  net-wireless/aircrack-ng \
  net-wireless/kismet \
  app-crypt/hashcat \
  app-crypt/johntheripper \
  net-analyzer/hydra \
  app-misc/binwalk \
  app-admin/checksec \
  dev-debug/gef \
  dev-util/pwntools \
  dev-util/radare2 \
  net-misc/proxychains
```

The rest (ffuf, gobuster, nuclei, subfinder, katana, amass, chisel, feroxbuster, netexec,
dnsrecon) installs with go, cargo or uv: see setup.md §11.

---

## not used: remove

These were installed during the install but aren't part of the system. Do this **after**
setup.md §3 (the switch to iwd) and §1.9 (autologin instead of greetd). `sys-apps/systemd`
stays installed because it's in @system. Deselecting it only drops a redundant @world entry.

```bash
sudo emerge --deselect gui-apps/waybar gui-apps/tuigreet gui-libs/greetd net-misc/networkmanager www-client/firefox app-editors/nano sys-apps/systemd
sudo emerge -a --depclean
```

## check

Shows anything in @world that isn't listed in this file (it should print nothing):

```bash
comm -13 <(grep -oE '^  [a-z0-9-]+/[^ ]+' ~/git/dots/gentoo/packages.md | tr -d ' ' | sort -u) <(sort /var/lib/portage/world)
```

