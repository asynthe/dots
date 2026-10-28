#!/usr/bin/env bash
# fcitx5 stays off by default: it breaks Hyprland focus (hyprwm/Hyprland#5764).
set -euo pipefail

unit="app-org.fcitx.Fcitx5@autostart.service"

if pgrep -x fcitx5 >/dev/null 2>&1; then
    systemctl --user stop "$unit" 2>/dev/null || pkill -x fcitx5 || true
    notify-send -a fcitx5 "fcitx5" "Stopped" 2>/dev/null || true
else
    systemctl --user start "$unit" 2>/dev/null || fcitx5 -d
    notify-send -a fcitx5 "fcitx5" "Started" 2>/dev/null || true
fi
