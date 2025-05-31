#! /usr/bin/env sh

# ADD
# - Set the open alacrittys fullscreen?
# - It seems to be working, but if we need custom alacritty font size, do script (?)
# - Add the [workspace 2; monitor 2] when another monitor is available.

# Testing - Working
hyprctl dispatch exec '[workspace 3 silent] alacritty -e tmuxp load ~/script/tmuxp/sysmonitor.yaml'
hyprctl dispatch exec '[workspace 4 silent] alacritty -e tmuxp load ~/script/tmuxp/animated.yaml'

# Two ways to do it:
# 1. Alacritty is executed running the 'tmuxp load' command
#hyprctl dispatch exec '[workspace 2; monitor 2] alacritty -e tmuxp load ~/script/tmuxp/sysmonitor.yaml'
# 2. Alacritty is executed then attaching itself to the session created before.
#hyprctl dispatch exec [workspace 1; monitor 2] alacritty -e '~/script/tmux/sysmonitor.yaml'
#hyprctl dispatch exec [workspace 1; monitor 3]
