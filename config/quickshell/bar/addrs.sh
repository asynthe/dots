#!/usr/bin/env bash

set -uo pipefail

defdev=$(ip -4 route get 1.1.1.1 2>/dev/null |
         sed -n 's/.*dev \([^ ]*\).*/\1/p' | head -1)

is_tunnel() {
    case "$1" in
        wg*|tun*|tailscale*|mullvad*|proton*) return 0 ;;
        *) return 1 ;;
    esac
}

ip -br -4 addr 2>/dev/null | while read -r dev _state rest; do
    [ "$dev" = "lo" ] && continue
    for cidr in $rest; do
        addr=${cidr%%/*}
        tag=""
        is_tunnel "$dev" && tag="vpn"
        [ "$dev" = "$defdev" ] && tag="default"
        case "$tag" in
            default) rank=0 ;;
            vpn)     rank=1 ;;
            *)       rank=2 ;;
        esac
        printf '%s\t%s\t%s\t%s\n' "$rank" "$dev" "$addr" "$tag"
    done
done | sort -t"$(printf '\t')" -k1,1n | cut -f2-
