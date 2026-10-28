#!/usr/bin/env bash
# Export the primary Google Calendar to a dated .ics.
set -euo pipefail

HERMES_AGENT_DIR="/home/meow/.local/share/hermes/hermes-agent"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="/home/meow/ben/backup/calendar"
OUT_FILE="${OUT_DIR}/calendar_backup_$(date +%Y%m%d).ics"

mkdir -p "$OUT_DIR"

cd "$HERMES_AGENT_DIR"
# shellcheck disable=SC1091
source activate
export PYTHONPATH="${HERMES_AGENT_DIR}:${PYTHONPATH:-}"
export HERMES_HOME="/home/meow/.local/share/hermes"

python3 "${SCRIPT_DIR}/export_calendar_ics.py" "$OUT_FILE"
