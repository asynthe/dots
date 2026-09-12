# Tide Island

Upstream: <https://github.com/enhaoswen/Tide-island>, pinned in `build.sh` at
`2b91fbd` (v1.0.38). Build script and config: `../config/quickshell/tide-island/`.

## It is not a quickshell config

This matters because it looks like one. Tide ships `shell.qml` and a `qml/`
tree, but `shell.qml` line 4 is `import IslandBackend`, and 28 of its 58 QML
files import the same module. `IslandBackend` is a compiled Qt plugin built
from `backend/*.cpp`, registering eight QML singletons: `UserConfig`,
`SysBackend`, `WifiController`, `StyleTokens`, `FileShelf`,
`CompositorBackend`, `SystemServices`, `BluetoothPairingAgent`.

Quickshell is only the runtime. Copying the QML into `~/.config/quickshell/`
fails on line 4 of the entry point.

So the install is a CMake build, not a symlink. `build.sh` does it, and works
the same on any distro — nothing in it is NixOS-specific except the devshell
branch.

## The eight things that had to be patched

Upstream targets a filesystem NixOS does not have, and assumes a mouse. All
eight fixes are applied
by `build.sh` there, so a rebuild keeps them.

1. **`#!/bin/bash`** in the launcher. There is no `/bin/bash` here. Rewritten
   to `#!/usr/bin/env bash`, which is also more portable than what upstream
   shipped.
2. **`/usr/bin/quickshell`**, hardcoded in three places. Replaced with a
   `command -v quickshell` lookup honouring `$QUICKSHELL_BIN`.
3. **Stripped install RPATH.** CMake blanks the non-toolchain RPATH on
   install, which on a distro with `/usr/lib` is correct and here leaves eight
   unresolved Qt libraries. `-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON` keeps the
   store paths.
4. **`Qt5Compat.GraphicalEffects`.** Not on the QML path from
   `systemPackages` alone. Handled outside this directory — see below.
5. **`/usr` baked into the config app.** `Tide-island-app/backend.cpp` holds
   `/usr/bin/quickshell` and `/usr/share/tide-island` as `constexpr`, not as
   CMake substitutions, and writes them into every shortcut it saves. Left
   alone, the config app writes binds pointing at paths that do not exist.
   Rewritten to `quickshell` on `PATH` and the real `$PREFIX`. This one breaks
   any `~/.local` install, not just NixOS.
6. **The systemd unit**, on both `ExecStart` and install location — see
   *Running it* below. Also breaks any `~/.local` install.
7. **`$PREFIX/bin` missing from `PATH`.** The shell resolves
   `tide-island-config-app` with a `PATH` lookup, and a systemd user session
   does not inherit the login shell's `PATH`, so the settings button silently
   found nothing. The launcher already computes `INSTALL_PREFIX`, so it now
   exports it. Breaks any `~/.local` install too.
8. **The auto-hide reveal band**, widened to the full screen — see
   *Auto-hide and the reveal band* below.

`~/.local/bin` additionally has to be on `PATH`: the shell resolves
`tide-island-config-app` with a `PATH` lookup, and warns at startup without it.
`environment.localBinInPath` in the aspect handles that.

## The system side

`nix/nixos/desktop/shell.nix` carries the `quickshell-tide-island` aspect: it
installs `qt6.qt5compat` and pins `QML2_IMPORT_PATH` to its store path. `p1`
opts in. This is the NixOS equivalent of `pacman -S qt6-5compat`, and is the
only part of Tide that lives in the flake — the build and the config stay
ordinary dotfiles.

## Rebuild after Qt updates

The binaries in `~/.local` link Qt by store path, and nothing garbage-collects
those paths as a root. When nixpkgs moves Qt forward and the old paths are
collected, Tide stops starting until `./build.sh` runs again. That is the
standing cost of not writing a derivation; a derivation is the fix if it ever
becomes annoying.

## Running it

`build.sh` writes `~/.config/systemd/user/tide-island.service`, because the unit
upstream installs is unusable here twice over: `ExecStart` is
`/usr/bin/tide-island`, and it lands in `~/.local/lib/systemd/user`, which
systemd does not search — only `~/.config/systemd/user` and
`~/.local/share/systemd/user`. The generated unit fixes the path and carries
`QML2_IMPORT_PATH` so it does not depend on the session having exported it.

Autostart is the line in `../config/hypr/hyprland.lua`, matching how hypridle
is started there:

    hl.exec_cmd("systemctl --user enable --now tide-island.service")

`enable` is idempotent, so the wiring lives in the dotfiles rather than only in
a symlink under `~/.config/systemd/user/graphical-session.target.wants/`.
`PartOf=graphical-session.target` stops it with the session; `Restart=on-failure`
covers crashes.

Running it from an interactive shell instead works, but the process dies with
the shell that launched it; `setsid` and `disown` do not save it.

## Shortcuts

`tide-island-config-app` writes a marker-delimited block into
`~/.config/hypr/hyprland.lua` — it detects the Lua config and emits proper
`hl.bind(..., hl.dsp.exec_cmd(...))` calls rather than legacy bind strings, so
the block works with the parser. It rewrites between its own markers and leaves
the rest of the file alone, but it is still an in-place edit of a tracked
dotfile: commit before running it.

Everything the shortcuts do is reachable by hand:

    quickshell ipc --any-display -p ~/.local/share/tide-island call <target> <fn>

Targets are `island` (show/open/reveal/hide/toggle, enable/disableAutoHide),
`overview` (toggle/open/close/refreshWallpaperCache), and `tide` (showClock,
showTimer, showCustom, showLyrics, swipeLeft, swipeRight, togglePlayer,
toggleControlCenter, togglePowerMenu, toggleNotificationCenter,
toggleApplicationLauncher, toggleFileShelf, toggleWallpaperPicker).

`quickshell -p ~/.local/share/tide-island ipc show` lists them from the running
instance.

## Notifications: mako stays

Tide has a notification centre, but it is **not** a notification daemon. It
never claims `org.freedesktop.Notifications`. `backend/SystemServices.cpp`
spawns `dbus-monitor` as a child and scrapes its stdout for `Notify` method
calls — upstream calls this "notification mirroring", and it is a passive
eavesdrop on traffic addressed to somebody else.

So something else still has to own the name and actually display, queue and
expire notifications. That is mako, in the `hyprland` aspect. Remove it and
nothing serves notifications at all — Tide's history goes empty too, because
there are no `Notify` calls on the bus to mirror.

`dbus-monitor` is a hard runtime dependency of that mirroring; it comes in with
dbus, so nothing extra is needed.

## Auto-hide and the reveal band

Upstream defaults `islandAutoHideEnabled` to true, and while it is on the
layer's input mask collapses to a single reveal box — `DynamicIslandWindow.qml`:

    autoHideRevealWidth  = max(islandWidth + 120, 240)   // 260px at the default 140
    autoHideRevealHeight = 10

Everything else on the layer is masked out, so on a 1920px screen the only
pointer-reachable part of the island was 260 x 10 px at the top centre, 13.5% of
the width. Vertically that is fine, since the cursor clamps at y=0. Horizontally
it is not, and a trackpad cannot fling-and-correct the way a mouse can: you run
out of pad, lift to reset, and drift out of the box. The same mask is what the
scroll-to-switch-pages gesture needs to sit inside, so revealing and paging both
got hard. There is no config key for either dimension.

`build.sh` patches the width to `root.width`, so hovering anywhere along the top
edge reveals it. The height stays 10px deliberately: that band is a real input
region, and it intercepts pointer events in the top 10px of whatever is
underneath. Ten pixels is a tolerable bite out of a maximised window's title bar
or tab strip; the island's full height would not be. Raise it in `build.sh` if
hovering still feels fussy, and lower `islandAutoHideDelayMs` (default 1000) if
it lingers too long before hiding.

With auto-hide on there is no exclusive zone — `hyprctl monitors` reserves 0 and
windows run under the island. Setting `islandAutoHideEnabled` to false is the
other option: permanently visible, full-width input, 45px reserved, which is the
old bar's behaviour.

`ALT + SHIFT + B` pins it open and hands it back to auto-hide, via the
`island disableAutoHide` / `enableAutoHide` IPC pair — `disableAutoHide` also
shows the island, and `enableAutoHide` re-evaluates so it hides again on its
own. That state lives in the running shell and cannot be read back, so the
keybind keeps a marker at `$XDG_RUNTIME_DIR/tide-pinned` to know which way to
go. The unit's `ExecStartPre` deletes it, otherwise a restart would leave the
toggle inverted.

## It replaced the bar

Tide occupies the top edge with a clock, battery, workspaces, media and tray —
the same set `../config/quickshell/bar/shell.qml` draws, so only one runs.
`../config/hypr/hyprland.lua` starts Tide instead, and its layer namespace is
plain `quickshell` rather than `quickshell:bar`, so the blur rule, the
hyprglass exclusion and the `ALT + SHIFT + B` toggle there were repointed.

The bar config is kept, not deleted: `qs -n -c bar` still runs it.

Tide animates its own exclusive zone and drops it to 0 when auto-hidden, so
unlike the bar it needs no fullscreen special-casing.

User config lives at `~/.config/tide-island/userconfig.json`, written by
`tide-island-config-app`.
