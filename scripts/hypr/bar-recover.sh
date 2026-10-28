#!/usr/bin/env bash
# Toggle the bar, relaunching it if it died.
if pgrep -f "bin/quickshell -c bar" >/dev/null; then
    exec qs -c bar ipc call bar toggle
fi
exec uwsm app -- qs -c bar
