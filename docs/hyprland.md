# Hyprland

Config lives in `config/hypr/hyprland.lua` (Lua config, Hyprland 0.5x+), with
monitor handling in `monitors.lua`. Helper scripts are under `scripts/hypr/`.

## No float-by-default rule

Floating every new window (`float = true, center = true` on `class = .*`) made
each window-open go through `setFloating()`. With hyprglass loaded, that hits
a dwindle-layout assert (`movedTarget`) and segfaults Hyprland (crash report
486048, 2026-10-26). Windows now open tiled and `ALT+SHIFT+F` floats one by
hand.

MusicBee (Wine) is the exception: its dialogs float, but they aren't centered.
Wine already places them relative to their owner window. The main window's
title always ends in ` - MusicBee`, so the rule excludes that title.

## Copilot key

The P1's Copilot key sends `LEFTMETA+F23` as one HID report. Hyprland's bind
matcher never fires on it, whatever the syntax (keysym `F23`, `code:201`,
`code:193`, with or without Super). The event itself shows up fine in evdev.
The likely cause is a race in modifier-then-key matching when both keys arrive
in a single report.

- **NixOS:** `nix/nixos/hardware/copilot-key.nix` makes keyd remap F23 to F13.
  keyd still holds `LEFTMETA+LEFTSHIFT` down at the same time (raw evdev on
  keyd's virtual device shows codes 125, 42 and 183 all down). So the bind is
  `code:191` with `ignore_mods = true`. Without it, a bind with modmask 0
  never fires.
- **Gentoo:** keyd runs `scripts/hypr/key-copilot-hermes.sh` as root through
  `command()`. The script drops to the user with `runuser`. On NixOS the keyd
  unit is too sandboxed for that.

In both cases the key toggles `special:copilot`, which holds a fullscreen
ghostty running Hermes.

## Focus nudge

A newly mapped window only gets keyboard focus after the pointer moves.
`spawn-terminal.sh` moves the cursor to where it already is after launching
ghostty. `focus-fix-daemon.py` does the same on every `openwindow` event.

## fcitx5

fcitx5 is off by default because of hyprwm/Hyprland#5764: the compositor
sends `ime::enter()` before `keyboard_enter()`, so newly focused windows
(ghostty especially) ignore keystrokes. `ALT+SHIFT+I` runs
`scripts/fcitx/toggle.sh` when an IME is needed.

## Glass and blur

hyprglass skips the desktop icons (`quickshell:desktop`), mpv, imv, Steam games,
XWayland windows and Mullvad. They redraw a lot and gain nothing from
refraction. The bar keeps the glass effect and draws a ~15% black background,
so the native blur-behind rule on `quickshell:bar` shows through it. The bar
layer has `no_anim`: when a menu opens the surface grows from 26px to 446px,
and animating that drags the whole bar along.

## Window placement

- The Hermes window is matched by class (`com.mitchellh.ghostty.hermes`).
  Hermes rewrites its title to the session name, so the title can't be used.
- `DesktopLaunchFloat` and `DesktopLaunchGame` are global rules that start
  disabled. `qs -c desktop` turns one on around a launch through
  `hyprctl eval`, so the app opens floating and centered, or without the fade
  for games.
- beatmania IIDX (TDJ) opens a 1920x1080 main window and a 1280x720 touch
  window, both borderless and pinned to those sizes. Monitor and move rules
  had no effect on these winewayland windows (tested 2026-09-28).
