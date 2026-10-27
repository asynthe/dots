#!/usr/bin/env bash
# Runs as the real user (invoked by copilot-toggle.sh via runuser). If the
# copilot scratchpad terminal was closed (window gone), relaunch it onto the
# hidden special:copilot workspace first, then (in both cases) toggle it
# visible/hidden — a fresh launch is hidden on the special workspace same as
# at session startup, so it still needs the toggle to actually show up.
set -euo pipefail

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

hyprctl dispatch "hl.dsp.workspace.toggle_special('copilot')"
