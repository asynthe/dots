#!/usr/bin/env bash

msg="[ raider :: gentoo install :: ssh active ]"

cleanup() {
  tput cnorm
  tput clear
}

trap cleanup EXIT INT TERM
tput civis

while true; do
  rows=$(tput lines)
  cols=$(tput cols)
  row=$((rows / 2))
  col=$(((cols - ${#msg}) / 2))
  tput clear
  tput cup "$row" "$col"
  echo -e "\033[1;32m$msg\033[0m"
  sleep 30
done
