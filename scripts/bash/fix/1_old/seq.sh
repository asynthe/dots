#!/usr/bin/env bash

today=$( date +%Y%m%d )   # or: printf -v today '%(%Y%m%d)T' -1
number=0

fname=$today.txt

while [ -e "$fname" ]; do
    printf -v fname '%s-%02d.txt' "$today" "$(( ++number ))"
done

printf 'Will use "%s" as filename\n' "$fname"
touch "$fname"
