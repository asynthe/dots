#!/usr/bin/env bash

# NOTE Copy this file as follows
# sudo mkdir -p /etc/udev/scripts
# sudo cp multi_monitor.sh /etc/udev/scripts/multi_monitor

USER=$(logname)
HOME_DIR=$(getent passwd "$USER" | cut -d: -f6)
CONFIG_DIR="$HOME_DIR/.config/hypr"
OUTPUT_FILE="$CONFIG_DIR/monitor.conf"
LAYOUT_DIR="$CONFIG_DIR/modules"

# Get the number of connected monitors
MONITORS=$(sudo -u "$USER" hyprctl monitors -j | jq length)

case "$MONITORS" in
  1) cp "$LAYOUT_DIR/monitor_one.conf" "$OUTPUT_FILE" ;;
  2) cp "$LAYOUT_DIR/monitor_two.conf" "$OUTPUT_FILE" ;;
  3) cp "$LAYOUT_DIR/monitor_three.conf" "$OUTPUT_FILE" ;;
  *) echo "# Unknown layout for $MONITORS monitor(s)" > "$OUTPUT_FILE" ;;
esac

sudo -u "$USER" hyprctl reload
