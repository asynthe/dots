#!/usr/bin/env bash
# Nemo dressed as Windows 11 Explorer. GTK_THEME only reaches a fresh nemo
# process: if nemo is already running under another theme, new windows join
# that one (nemo -q quits it).
export GTK_THEME=Fluent-Dark
exec nemo "$@"
