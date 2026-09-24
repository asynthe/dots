#!/usr/bin/env bash

set -uo pipefail

out=$(ping -c 1 -W 2 -n -q 1.1.1.1 2>/dev/null) || { echo -1; exit 0; }

rtt=$(printf '%s' "$out" | sed -n 's|.*= [0-9.]*/\([0-9.]*\)/.*|\1|p')
[ -z "$rtt" ] && { echo -1; exit 0; }

printf '%.0f\n' "$rtt"
