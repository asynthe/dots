#!/usr/bin/env bash
# Toggles the hermes scratchpad terminal, relaunching it if closed.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    export XDG_RUNTIME_DIR="/run/user/1000"
    sig=$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -1)
    exec runuser -u meow -- env \
        XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        HYPRLAND_INSTANCE_SIGNATURE="$sig" \
        "$0"
fi

lock="${XDG_RUNTIME_DIR:-/tmp}/copilot-toggle.lock"
exec 9>"$lock"
flock -w 5 9 || exit 1

class="com.mitchellh.ghostty.copilot"
addr=$(hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class==$c) | .address' | head -1)

if [ -z "$addr" ]; then
    hyprctl dispatch "hl.dsp.exec_cmd('[workspace special:copilot silent] ghostty --class=$class -e hermes')"
    for _ in $(seq 1 50); do
        addr=$(hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class==$c) | .address' | head -1)
        [ -n "$addr" ] && break
        sleep 0.1
    done
fi

flock -u 9

hyprctl dispatch "hl.dsp.workspace.toggle_special('copilot')"
