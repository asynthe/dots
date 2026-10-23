#!/usr/bin/env bash
# Called by keyd (running as root) when the Copilot key's F23 scancode
# fires. This bypasses Hyprland's own keybind matcher entirely: extensive
# testing confirmed the raw hardware key (LEFTMETA+F23, fired as a single
# simultaneous USB HID chord with ~0ms between them) always arrives fine at
# the evdev/libinput level, with or without keyd in the path, but no
# Hyprland bind syntax (keysym "F23", "code:201", "code:193", with or
# without the Super modifier) ever fired — most likely a race in Hyprland's
# modifier-then-key bind matching against a chord delivered in one HID
# report rather than two sequential presses. keyd intercepts the raw F23
# scancode directly (before Hyprland ever sees it) and runs this script as
# root, so it has to drop to the real user to reach the user's own
# Hyprland/Wayland session.
set -euo pipefail

export XDG_RUNTIME_DIR="/run/user/1000"
sig=$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -1)

runuser -u meow -- env \
  XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  HYPRLAND_INSTANCE_SIGNATURE="$sig" \
  hyprctl dispatch "hl.dsp.workspace.toggle_special('copilot')"
