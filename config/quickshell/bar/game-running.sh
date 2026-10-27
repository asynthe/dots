#!/usr/bin/env bash
# Prints "1" if a Steam game actually appears to be running (not just the
# Steam client itself, which idles at low CPU and shouldn't hide the bar),
# "0" otherwise. Same detection pattern as the linux-system-diagnostics
# skill: a reaper/proton process or anything running out of
# steamapps/common means a game is active. Excludes the kernel's own
# [oom_reaper] kthread (bracketed, false-matched "reaper" otherwise) and
# steamwebhelper (part of the client itself, not a game).
if pgrep -af "SteamLaunch|proton|steamapps/common" 2>/dev/null |
    grep -v "grep\|steamwebhelper" -q; then
    echo 1
else
    echo 0
fi
