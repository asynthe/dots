#!/bin/bash

backup_dir="/home/$(whoami)/sync/ben/backup/notes"
keep_backups=5

# Calculate the current time in the same format as the file names
current_time=$(date +'%Y%m%d_%H%M')

# Loop through the backups and keep only the latest 5
backup_files=("$backup_dir"/*_notes.tar.gz)  # Adjust the pattern to match your file names

# Sort the backup files by name (chronologically)
sorted_files=($(printf "%s\n" "${backup_files[@]}" | sort))

# Calculate the number of backups to remove
backups_to_remove=$(( ${#sorted_files[@]} - keep_backups ))

if [ "$backups_to_remove" -gt 0 ]; then
    # Remove the oldest backups
    for ((i = 0; i < backups_to_remove; i++)); do
        rm "${sorted_files[i]}"
    done
fi
