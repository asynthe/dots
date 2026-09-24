#!/usr/bin/env bash

set -uo pipefail

row() { printf '%s\t%s\n' "$1" "$2"; }

ff() {
    fastfetch --logo none --pipe -s "$1" 2>/dev/null |
        sed -n 's/^\([^:]*\): *\(.*\)$/\1\t\2/p'
}

human() {
    awk -v b="${1:-0}" 'BEGIN {
        split("B KB MB GB TB", u, " ")
        i = 1
        while (b >= 1024 && i < 5) { b /= 1024; i++ }
        printf (i == 1 ? "%d %s\n" : "%.1f %s\n"), b, u[i]
    }'
}

case "${1:-system}" in

system)
    all=$(fastfetch --logo none --pipe \
              -s "os:host:kernel:uptime:packages:wm:cpu:gpu:battery:locale" \
          2>/dev/null)

    field() {
        printf '%s' "$all" | sed -n "s/^$1: *//p" | head -1
    }

    os=$(field "OS" | sed 's/ *\(x86_64\|aarch64\|i686\)$//')
    [ -n "$os" ] && row "OS" "$os"

    host=$(field "Host")
    case "$host" in
        *\(*\)*) host=$(printf '%s' "$host" | sed 's/.*(\(.*\)).*/\1/') ;;
    esac
    [ -n "$host" ] && row "Host" "$host"

    kernel=$(field "Kernel")
    [ -n "$kernel" ] && row "Kernel" "$kernel"

    uptime=$(field "Uptime")
    [ -n "$uptime" ] && row "Uptime" "$uptime"

    packages=$(field "Packages")
    [ -n "$packages" ] && row "Packages" "$packages"

    wm=$(field "Window Manager" | sed 's/ *([^)]*)$//')
    [ -n "$wm" ] && row "Window Manager" "$wm"

    cpu=$(field "CPU" | sed 's/ *([0-9+]*)//; s/ *@ *[0-9.]* *[GM]Hz//')
    [ -n "$cpu" ] && row "CPU" "$cpu"

    gpu=$(printf '%s' "$all" | sed -n 's/^GPU[ 0-9]*: *//p' |
          grep -i nvidia | head -1 |
          sed 's/ *Ada Generation//; s/ *Laptop GPU//; s/ *@ *[0-9.]* *[GM]Hz//; s/ *\[Integrated\]//')
    [ -z "$gpu" ] && gpu=$(printf '%s' "$all" | sed -n 's/^GPU[ 0-9]*: *//p' | head -1)
    [ -n "$gpu" ] && row "GPU" "$gpu"

    battery=$(field "Battery ([^)]*)")
    [ -z "$battery" ] && battery=$(field "Battery")
    [ -n "$battery" ] && row "Battery" "$battery"

    loc=$(field "Locale")
    if [ -n "$loc" ]; then
        case "$loc" in
            en_*) lang="English"    ;;
            es_*) lang="Spanish"    ;;
            pt_*) lang="Portuguese" ;;
            fr_*) lang="French"     ;;
            de_*) lang="German"     ;;
            it_*) lang="Italian"    ;;
            ja_*) lang="Japanese"   ;;
            zh_*) lang="Chinese"    ;;
            *)    lang=""           ;;
        esac
        [ -n "$lang" ] && row "Language" "$lang ($loc)" || row "Language" "$loc"
    fi
    ;;

network)
    defdev=$(ip -4 route get 1.1.1.1 2>/dev/null |
             sed -n 's/.*dev \([^ ]*\).*/\1/p' | head -1)

    [ -n "$defdev" ] && row "Interface" "$defdev"

    gw=$(ip -4 route show default 2>/dev/null |
         sed -n 's/^default via \([0-9.]*\).*/\1/p' | head -1)
    [ -n "$gw" ] && row "Gateway" "$gw"

    dns=$(resolvectl dns 2>/dev/null |
          sed -n 's/.*: *//p' | tr ' ' '\n' | grep -E '^[0-9.]+$' |
          sort -u | paste -sd' ' -)
    [ -z "$dns" ] && dns=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf 2>/dev/null |
                           paste -sd' ' -)
    [ -n "$dns" ] && row "DNS" "$dns"

    if [ -n "$defdev" ] && [ -d "/sys/class/net/$defdev" ]; then
        mac=$(cat "/sys/class/net/$defdev/address" 2>/dev/null)
        [ -n "$mac" ] && row "MAC" "$mac"

        rx=$(cat "/sys/class/net/$defdev/statistics/rx_bytes" 2>/dev/null)
        tx=$(cat "/sys/class/net/$defdev/statistics/tx_bytes" 2>/dev/null)
        [ -n "$rx" ] && row "Received" "$(human "$rx")"
        [ -n "$tx" ] && row "Sent" "$(human "$tx")"
    fi

    ip -br -4 addr 2>/dev/null | while read -r dev state rest; do
        [ "$dev" = "lo" ] && continue
        [ "$dev" = "$defdev" ] && continue
        [ "$state" != "UP" ] && continue
        row "$dev" "${rest%% *}"
    done
    ;;

audio)
    sink=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null |
           sed -n 's/.*node\.description = "\(.*\)"/\1/p' | head -1)
    row "Output" "${sink:-none}"

    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [ -n "$vol" ]; then
        pct=$(awk '{ printf "%d%%", $2 * 100 }' <<< "$vol")
        case "$vol" in *MUTED*) pct="$pct (muted)" ;; esac
        row "Volume" "$pct"
    fi

    src=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ 2>/dev/null |
          sed -n 's/.*node\.description = "\(.*\)"/\1/p' | head -1)
    row "Input" "${src:-none}"

    rate=$(pw-metadata -n settings 2>/dev/null |
           sed -n "s/.*key:'clock.rate' value:'\([0-9]*\)'.*/\1/p" | head -1)
    quantum=$(pw-metadata -n settings 2>/dev/null |
              sed -n "s/.*key:'clock.quantum' value:'\([0-9]*\)'.*/\1/p" | head -1)

    [ -n "$rate" ] && row "Sample rate" "$rate Hz"
    if [ -n "$rate" ] && [ -n "$quantum" ] && [ "$rate" -gt 0 ]; then
        row "Buffer" "$quantum ($(awk -v q="$quantum" -v r="$rate" \
            'BEGIN { printf "%.1f ms", q / r * 1000 }'))"
    fi

    [ -n "$rate" ] && [ "$rate" != "44100" ] &&
        row "Note" "not 44.1k -- konaste will loop back"

    streams=$(pw-dump 2>/dev/null |
              jq '[.[] | select(.info.props["media.class"] == "Stream/Output/Audio")] | length' \
              2>/dev/null)
    [ -n "$streams" ] && row "Playing" "$streams stream(s)"
    ;;

display)
    hyprctl monitors -j 2>/dev/null |
        jq -r '.[] | "\(.name)\t\(.width)x\(.height) @ \(.refreshRate | round) Hz  x\(.scale)\(if .focused then "  *" else "" end)"' \
        2>/dev/null

    bl=$(brightnessctl --machine-readable 2>/dev/null | head -1)
    if [ -n "$bl" ]; then
        row "Backlight" "$(cut -d',' -f4 <<< "$bl")"
    fi

    ff "gpu"
    ;;

storage)
    df -h --output=source,target,size,used,pcent -x tmpfs -x devtmpfs \
       -x efivarfs -x overlay 2>/dev/null |
    tail -n +2 |
    awk '!seen[$1]++ { printf "%s\t%s used of %s  (%s)\n", $2, $4, $3, $5 }'

    lsblk -dno NAME,SIZE,MODEL 2>/dev/null |
        awk 'NF { name = $1; size = $2; $1 = $2 = ""; sub(/^ +/, "")
                  printf "%s\t%s%s\n", name, size, ($0 == "" ? "" : "  " $0) }'
    ;;

*)
    row "error" "unknown pane: $1"
    exit 1
    ;;
esac
