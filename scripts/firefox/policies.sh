#! /usr/bin/env bash

set -euo pipefail

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

DOTS="$(cd "$(dirname "$0")/../.." && pwd)"
OUT=/etc/firefox/policies/policies.json

y='\033[1;33m'; g='\033[0;32m'; nc='\033[0m'
note() { echo -e "  ${g}[+]${nc} $*"; }
warn() { echo -e "  ${y}[!]${nc} $*"; }

# Force-installed in every profile from AMO's latest.xpi. Slugs come from
# addons.mozilla.org/api/v5/addons/addon/<id>/; the theme is picked in common.cfg.
ADDONS=(
    "{a7589411-c5f6-41cf-8bdc-f66527d9d930}  matte-black-red"
    "uBlock0@raymondhill.net                 ublock-origin"
    "addon@darkreader.org                    darkreader"
    "jid1-BoFifL9Vbdl2zQ@jetpack             decentraleyes"
    "idcac-pub@guus.ninja                    istilldontcareaboutcookies"
    "{de22fd49-c9ab-4359-b722-b3febdc3a0b0}  popup-blocker"
    "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}  auto-tab-discard"
    "tabcenter-reborn@ariasuni               tabcenter-reborn"
    "myallychou@gmail.com                    youtube-recommended-videos"
    "{00000f2a-7cde-4f20-83ed-434fcb420d71}  imagus"
    "{6b733b82-9261-47ee-a595-2dda294a4d08}  yomitan"
    "{6AC85730-7D0F-4de0-B3FA-21142DD85326}  colorzilla"
    "{c3c10168-4186-445c-9c5b-63f12b8e2c87}  cookie-editor"
    "wappalyzer@crunchlabz.com               wappalyzer"
    "foxyproxy@eric.h.jung                   foxyproxy-standard"
)

echo "── firefox policies"
command -v jq >/dev/null || { warn "jq not found"; exit 1; }

json=$(printf '%s\n' "${ADDONS[@]}" | jq -Rn '{policies: {ExtensionSettings: ([inputs
    | splits(" +") as $f | select($f != "") | $f] | [range(0; length; 2) as $i | {(.[$i]):
    {installation_mode: "force_installed",
     install_url: ("https://addons.mozilla.org/firefox/downloads/latest/" + .[$i+1] + "/latest.xpi")}}]
    | add)}}')
note "${#ADDONS[@]} add-ons"

theme=$(sed -n 's/.*"extensions.activeThemeID", *"\([^"]*\)".*/\1/p' "$DOTS/config/firefox/common.cfg")
if [ -n "$theme" ] && ! printf '%s\n' "${ADDONS[@]}" | grep -qF "$theme"; then
    warn "common.cfg's theme $theme is not in ADDONS — it would never be installed"
fi

if [ -f "$OUT" ] && [ "$(jq -S . "$OUT")" = "$(jq -S . <<< "$json")" ]; then
    note "$OUT is up to date"
    exit 0
fi

if [ $APPLY -eq 1 ]; then
    sudo mkdir -p "$(dirname "$OUT")"
    sudo tee "$OUT" <<< "$json" >/dev/null
    note "wrote $OUT — restart Firefox to pick it up"
else
    [ -f "$OUT" ] && diff <(jq -S . "$OUT") <(jq -S . <<< "$json") | sed 's/^/    /' || true
    echo -e "\n${y}dry run — re-run with --apply${nc}"
fi
