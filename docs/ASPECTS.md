# Aspect notes

Why the non-obvious aspects are written the way they are. One section per file
under `nix/nixos/`; anything not listed here is plain enough to read. The code
carries no comments, so this is where that knowledge lives — see
[DENDRITIC.md](DENDRITIC.md) for what an aspect *is*.

## base/core.nix

Imported by every host: nix daemon settings, the nixpkgs instance, the shell.
Impermanence's module is imported unconditionally so any aspect can declare
persistence without checking whether the host wipes root.

`flannel` 0.28.6 has a wrong source hash in nixpkgs; the overlay pins the real
one from upstream. Drop it when nixpkgs is fixed.

Seat groups (`audio`, `networkmanager`) go to every admin, not to a named user
— see [AUTH.md](AUTH.md). `scripts/home_setup.sh` links the `scripts/bin`
wrappers into `~/.local/bin`; the aspect only puts the directory on `PATH`.

## base/cli.nix

The shell environment every host gets, so everything in it has to be defensible
on a headless box. Tools that belong to a subsystem live with that subsystem
instead. `ghostty.terminfo` is here because ssh *from* a ghostty client needs
the entry on this end too.

## base/boot.nix

`boot-silent` replaces systemd-boot's output; import it *instead of* `boot`,
never alongside.

## base/security.nix

Changing `pinentryPackage` needs a `pkill gpg-agent` before it takes effect —
the running agent holds the old one.

`sys.sops.ageKeyFile` defaults outside `/home` because activation unlocks
passwords before `/home` is guaranteed mounted. [SECRETS.md](SECRETS.md) has
the rest.

## base/net.nix

`iwd` is enabled for the `impala` TUI. The open TODOs are a backend split
(NetworkManager vs iwd), per-laptop IPv6 and address randomisation, and a udev
rule for ethernet MAC randomisation.

## share.nix

Publishes directories to another account by bind mount, and opens the writable
ones to the `share` group with a default ACL so they stay group-writable
whatever umask the other side used. [AUTH.md](AUTH.md) covers the accounts, why
it is a bind mount rather than a symlink, and the one-time `setfacl`.

## desktop/hyprland.nix

The session is started from zsh's `.zprofile` with `uwsm start`, which `exec`s
— so nothing after it in `.zprofile` runs, and the unit cannot be enabled from
there. `getty` autologins tty1 only, once per boot; tty2-6 still prompt.

Only things that presuppose a running Hyprland belong in the session bundle.

`hyprglass` builds against `config.programs.hyprland.package` so the plugin ABI
always matches the running compositor; upstream's Makefile has no install
target, hence the manual install phase. See [HYPRGLASS.md](HYPRGLASS.md).

`hyprland-flake` tracks the Hyprland flake instead of nixpkgs, and is imported
*alongside* `hyprland`; the plugin aspects that depend on it are pointless
against the nixpkgs build.

## desktop/look.nix

If fonts look wrong, try `fc-cache -f` first.

The `defaultFonts` block is the whole font policy: app configs ask for a role
(monospace, sansSerif, serif), never a family. Terminals (TX-02) and Firefox
are the two deliberate exceptions.

TX-02 is licensed and unpacked by hand, with JetBrainsMono NF behind it for the
icons it lacks. In `localConf` it is escaped as `TX\-02` — a bare `TX-02`
pattern parses as family `TX` at size 2.

`adwaita-icon-theme` is named explicitly because `gtk-icon-theme-name` points
at it and Qt reaches it through qgtk3. `QT_QPA_PLATFORMTHEME` is set here
rather than only in `hyprland.lua` because `uwsm app` inherits the systemd user
environment; qgtk3 derives its palette from `GTK_THEME`, so no
`QT_STYLE_OVERRIDE` is needed.

`font-manager` is the fuller glyph browser but pulls webkitgtk; `fontpreview`
and `gucharmap` cover most of it.

## desktop/apps.nix

Nemo needs `gvfs` (trash, USB and network mounts) and `tumbler` (thumbnails);
it pulls in neither and fails silently without them. `-with-extensions` is the
package to install — plain `nemo` ships without fileroller and cannot open an
archive. The `inode/directory` default is what gives `xdg-open` and Firefox's
"open containing folder" something to hand a directory to. Nemo reads
Cinnamon's terminal key, so without the dconf override it launches
gnome-terminal, which is not installed; `programs.dconf` itself comes from the
`virtualisation` aspect.

The `org/gnome/desktop/interface` keys are there because **GTK reads dconf
before `gtk-3.0/settings.ini`**, so they silently win over the repo's
`gtk-font-name`. They were previously set by hand, and shipped as
`Segoe UI 9` / `Hack 10` — neither font installed — which is why Firefox's
chrome ignored the dotfiles entirely. Keep them in step with
`config/gtk-{3,4}.0/settings.ini`.

## desktop/firefox.nix

Drops the default (no-container) profile's cookies and site storage each login,
so `personal`, `study` and `events` keep their logins and everything else is
transient. `scripts/firefox_clean.sh` does the work.

It runs at login rather than on a timer: Firefox keeps cookies in memory and
flushes them back over any outside edit, so the script needs the profile to
itself, and `graphical-session-pre` is the only point that can promise that.
Exit status 1 means "Firefox was already up, skipped" and is accepted as
success so a session is never held up by it.

## desktop/xdg.nix

XDG base directories and the per-app redirects that keep `$HOME` flat, see
[HOME_STRUCTURE.md](HOME_STRUCTURE.md). An app only lands here if it honours an
env var — steam, factorio, mixxx, stepmania and vscode hardcode a dotfile and
cannot be fixed from this side; `xdg-ninja` lists them.

In `user-dirs.defaults` an empty value means `$HOME`, which is what stops the
unused folders from being auto-created. The base dirs are the spec defaults but
are set explicitly so the redirects below can reference them. The wine entry is
a fallback for a bare `wine foo.exe` with no prefix set; the real layout is
`~/wine/prefix/<app>`.

## desktop/shell.nix

Wayland shells: bar, launcher, notifier, lockscreen. Kept out of the `hyprland`
session bundle because which shell runs is a choice a host makes. Quickshell is
a toolkit, not a shell — nothing runs until the runner is pointed at a config —
and the Qt tooling it installs (`qmlls`, `qmlformat`, `qmllint`) is the point,
since editing the config is the whole job. Each config shells out to its own
tools; `hyprquickpaper`'s all come from elsewhere in the tree.

## hardware/laptop.nix

`upower` publishes battery, lid and AC state over dbus, which is what every
shell's battery widget reads. `power-profiles-daemon` is the switch those
widgets write to, and it is mutually exclusive with tlp and auto-cpufreq.
Charge history and the capacity estimate are persisted because both take days
to rebuild.

Lid handling: suspend on battery, suspend on AC with no external display,
ignore when docked.

## hardware/gpu.nix

`nvidia-prime` is offload mode: it needs the `intel-gpu` aspect and both bus
IDs set on the host. `modesetting` is the X driver; `intel` is for older parts.
`LIBVA_DRIVER_NAME=iHD` selects Intel VA-API through intel-media-driver.

## hardware/peripherals.nix

The `controller` aspect is the PS5 pad; it pairs over bluetooth, so import
`bluetooth` with it.

## net/vpn.nix

Mullvad wins the default route and swallows the tailnet. The firewall marks
hand tailnet packets back to `tailscale0` —
[upstream note](https://mullvad.net/en/help/split-tunneling-with-linux-advanced).
The hook priorities are load-bearing: output must be between -200 and 0 and
input between -100 and 0, or the tunnel IP leaks with no error. The
[NixOS wiki page](https://wiki.nixos.org/wiki/Mullvad_VPN) is the other half.

## net/tools.nix

`soc-tools` is defensive tooling; `pentest` is offensive and several GB, split
out so a server can import one without the other. Wireshark's setcap wrapper
and the `dumpcap` group are what let capture run unprivileged.

## net/wazuh-syslog.nix

Ships this host's journal to the Wazuh manager's syslog listener. The manager
lives in `~/git/flakes` on `sarten`; this is only the client. journald stays
the log store — the instance forwards and nothing else — and it is UDP because
that is the only 514 the compose file publishes.

## dev/database.nix

Three aspects, so a host can take the tooling without running a server.
`database` is the CLI kit, `database-gui` is DBeaver alone (a ~700 MB Java
closure — kept separate so a headless host never pulls it), and
`postgres-local` is the server.

`postgres-local` persists `/var/lib/postgresql` when the host wipes root;
without that line a practice database does not survive a reboot on `p1`. Its
`authentication` block is `trust` on loopback only and uses `mkForce` to
replace the NixOS default rather than append to it — order matters in
`pg_hba.conf`, and an appended rule after the default `peer` line never
matches. This is a throwaway learning database on a laptop; do not copy the
block to `~/git/flakes`.

See [DATABASE.md](DATABASE.md) for what to actually do with it.

## dev/tools.nix

`deploy-rs` drives `~/git/flakes`: `deploy .#<host>`, with `ssh-to-age` for
per-host sops keys.

## dev/virtualisation.nix

`vfio` binds the GPU to `vfio-pci` — import it alongside `virtualisation`, and
only on a host that has a second GPU to give away. The swtpm state directory
needs its permissions fixed by hand, which is what the tmpfiles rule is for.

## gaming.nix

The wine package is pinned through `nixpkgs-wine`: 11.16 breaks MusicBee and
11.14 is the last good one. It is listed first so its `wine` wins over
`wineWayland`'s.

`star-citizen-cache` is only useful with `star-citizen`. The PS3 emulator is an
upstream binary and x86_64-linux only. `emulation-station` was dropped from
nixpkgs on 2025-10-23 over freeimage CVEs and is packaged here from the
AppImage.
