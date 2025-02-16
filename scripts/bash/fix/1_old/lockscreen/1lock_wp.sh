#!/bin/sh

for x in HDMI-A-2 eDP-1
do
	grim -o "$x" "/tmp/$x.png"
	convert "/tmp/$x.png" -filter Gaussian -blur 0x6 "/tmp/$x.png" &
done
wait
exec gtklock "$@"
