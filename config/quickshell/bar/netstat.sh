#!/usr/bin/env bash

set -uo pipefail

IWD=net.connman.iwd

read -r ip dev < <(
    ip -4 route get 1.1.1.1 2>/dev/null |
    sed -n 's/.*dev \([^ ]*\).*src \([0-9.]*\).*/\2 \1/p' | head -1
)
ip=${ip:-}
dev=${dev:-}

if [ -z "$ip" ]; then
    printf '%d\t%d\t%s\t%s\t%s\n' -1 0 "offline" "" "no route"
    exit 0
fi

case "$dev" in
    wg*|tun*|tailscale*|mullvad*|proton*) flag=vpn ;;
    *)                                   flag=lan ;;
esac

station=$(busctl tree $IWD 2>/dev/null |
          grep -oE '/net/connman/iwd/[0-9]+/[0-9]+$' | head -1)

if [ -z "$station" ]; then
    printf '%d\t%d\t%s\t%s\t%s\n' -1 0 "$ip" "$flag" "${dev:-link}"
    exit 0
fi

state=$(busctl get-property $IWD "$station" net.connman.iwd.Station State 2>/dev/null |
        sed 's/^s "//; s/"$//')

if [ "$state" != "connected" ]; then
    printf '%d\t%d\t%s\t%s\t%s\n' -1 0 "$ip" "$flag" "${dev:-link}"
    exit 0
fi

connected=$(busctl get-property $IWD "$station" net.connman.iwd.Station ConnectedNetwork 2>/dev/null |
            sed 's/^o "//; s/"$//')

rssi=$(busctl --json=short call $IWD "$station" net.connman.iwd.Station \
           GetOrderedNetworks 2>/dev/null |
       jq -r --arg want "$connected" \
           '.data[0][] | select(.[0] == $want) | .[1]' 2>/dev/null | head -1)

if [ -z "$rssi" ]; then
    printf '%d\t%d\t%s\t%s\t%s\n' -1 0 "$ip" "$flag" "${dev:-link}"
    exit 0
fi
rssi=$(( rssi / 100 ))

ssid=$(printf '%s' "${connected##*/}" |
       sed 's/_[a-z0-9]*$//' |
       sed 's/\(..\)/\\x\1/g' |
       xargs -0 printf 2>/dev/null)
ssid=${ssid:-wifi}

if   [ "$rssi" -ge -50 ]; then bars=4
elif [ "$rssi" -ge -60 ]; then bars=3
elif [ "$rssi" -ge -70 ]; then bars=2
elif [ "$rssi" -ge -80 ]; then bars=1
else                           bars=0
fi

printf '%d\t%d\t%s\t%s\t%s\n' "$bars" "$rssi" "$ip" "$flag" "$ssid"
