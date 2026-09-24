#!/usr/bin/env bash

CONFIG="$1/config.json"

wallpaper_path=$(jq -r '.wallpaper_path' "$CONFIG")
cache_path=$(jq -r '.cache_path' "$CONFIG")
cache_batch_size=$(jq -r '.cache_batch_size' "$CONFIG")

mkdir -p "$cache_path"

echo "Wallpaper path: $wallpaper_path"
echo "Cache path: $cache_path"

TILE=(-resize x800^ -gravity center -extent 500x800 -strip -quality 88)

find "$wallpaper_path" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" \
\) | while read -r src; do

    filename=$(basename "$src")
    out="$cache_path/$filename.jpg"

    if [[ -f "$out" ]]; then
        continue
    fi

    echo "Generating thumbnail for $filename"
    magick "$src" "${TILE[@]}" "$out" &

    if (( cache_batch_size > 0 )); then
        while (( $(jobs -rp | wc -l) >= cache_batch_size )); do
            wait -n
        done
    fi

done

wait

echo "Thumbnail generation complete."
