#!/bin/bash

backup_dir="~/sync/ben/backup/notes"
interval_hours=3

# Calculate the current time in the same format as the file names
current_time=$(date +'%Y%m%d_%H%M')

# Loop through the backups and keep only the latest from each 3-hour interval
for file in "$backup_dir"/*_notes.zip; do
    timestamp=$(echo "$file" | grep -oE '[0-9]{12}_[0-9]{4}')
    
    if [ -n "$timestamp" ]; then
        file_time=$(date -d "$timestamp" +'%Y%m%d_%H%M')
        hours_diff=$(( (current_time - file_time) / 100 ))
        
        if [ "$hours_diff" -ge "$interval_hours" ]; then
            rm "$file"
        fi
    fi
done
