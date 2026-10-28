#!/usr/bin/env bash
# 1 while a Steam game runs, the client alone does not count.
if pgrep -af "SteamLaunch|proton|steamapps/common" 2>/dev/null |
    grep -v "grep\|steamwebhelper" -q; then
    echo 1
else
    echo 0
fi
