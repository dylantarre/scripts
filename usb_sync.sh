#!/bin/bash

# Names of USB drives to watch for
TARGET_NAMES=("AQUA" "SILVER")

# Folder on your Mac to sync from
SOURCE_FOLDER="/Users/dylantarre/Documents/Embroidery/Machine"

# Loop through mounted volumes
for disk in /Volumes/*; do
  name=$(basename "$disk")
  for target in "${TARGET_NAMES[@]}"; do
    if [[ "$name" == "$target" ]]; then
      DEST="$disk/Backup"

      echo "USB '$name' detected. Checking space..."

      # Get free space on the disk in kilobytes
      free_kb=$(df -k "$disk" | tail -1 | awk '{print $4}')
      # Estimate size of source folder in kilobytes
      source_kb=$(du -sk "$SOURCE_FOLDER" | awk '{print $1}')

      if (( free_kb < source_kb )); then
        echo "Not enough space on '$name'. Sync skipped."
        afplay /System/Library/Sounds/Basso.aiff  # Warning sound
        continue
      fi

      echo "Enough space. Proceeding with sync..."

      rm -rf "$DEST"
      mkdir -p "$DEST"

      rsync -av --delete "$SOURCE_FOLDER/" "$DEST/"

      afplay /System/Library/Sounds/Glass.aiff  # Success chime

      echo "Sync to '$name' complete."

      # Flush and eject
      sync
      sleep 2
      diskutil eject "$disk"

      # Play ejection sound
      afplay /System/Library/Sounds/Blow.aiff
    fi
  done
done