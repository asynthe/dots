#!/bin/bash

# Note: '-C' -> Change the current directory to this path, and from this path compress a folder or file.
# Putting '~/sync/notes .' instead will take notes as the main directory, so If extracted, 
# all files will be extracted, instead of a "notes" subdirectory.

tar -czf ~/sync/ben/backup/notes/"$(date +'%Y%m%d_%H%M')_notes.tar.gz" -C ~/sync notes
