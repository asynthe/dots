#!/usr/bin/env bash
# Toggle fcitx5 on/off.
#
# Off by default (see ~/.config/autostart/org.fcitx.Fcitx5.desktop,
# Hidden=true) because fcitx5 + Hyprland's text-input-v3 relay race on
# keyboard focus changes (upstream bug, hyprwm/Hyprland#5764: "compositor
# sent ime::enter() event before the corresponding keyboard_enter() event").
# Symptom: a newly focused window (especially ghostty) doesn't receive
# keyboard input until you manually move the mouse over it or refocus.
# Confirmed on this machine 2026-10-18: opening several ghostty windows
# in a row leaves the last one unable to receive keystrokes while fcitx5
# is running; stopping fcitx5 fixes it immediately.
#
# Start this on demand only when you need an IME (Japanese, etc.) and
# stop it again when done.
set -euo pipefail

unit="app-org.fcitx.Fcitx5@autostart.service"

if pgrep -x fcitx5 >/dev/null 2>&1; then
    systemctl --user stop "$unit" 2>/dev/null || pkill -x fcitx5 || true
    notify-send -a fcitx5 "fcitx5" "Stopped" 2>/dev/null || true
else
    systemctl --user start "$unit" 2>/dev/null || fcitx5 -d
    notify-send -a fcitx5 "fcitx5" "Started" 2>/dev/null || true
fi
