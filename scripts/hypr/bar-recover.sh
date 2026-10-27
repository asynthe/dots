#!/usr/bin/env bash
# ALT+SHIFT+B: toggles the bar's visibility; relaunches it first if it
# ever crashed/got killed (a plain IPC toggle is a no-op then, since
# there's nothing running to IPC into).
if pgrep -f "bin/quickshell -c bar" >/dev/null; then
    exec qs -c bar ipc call bar toggle
fi
exec uwsm app -- qs -c bar
