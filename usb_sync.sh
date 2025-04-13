#!/bin/bash

TARGET_NAMES=("AQUA" "SILVER")
SOURCE_FOLDER="/Users/dylantarre/Documents/Embroidery/Machine/"
LOGDIR="${SOURCE_FOLDER}logs"
LOGFILE="${LOGDIR}/sync.log"

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

mkdir -p "$LOGDIR"
echo "[$(timestamp)] Sync script started." >> "$LOGFILE"

for disk in /Volumes/*; do
  name=$(basename "$disk")
  for target in "${TARGET_NAMES[@]}"; do
    if [[ "$name" == "$target" ]]; then
      DEST="$disk/Backup"

      echo "[$(timestamp)] USB '$name' detected. Checking space..." >> "$LOGFILE"

      free_kb=$(df -k "$disk" | tail -1 | awk '{print $4}')
      source_kb=$(du -sk "$SOURCE_FOLDER" | awk '{print $1}')

      if (( free_kb < source_kb )); then
        echo "[$(timestamp)] Not enough space on '$name'. Required: ${source_kb}KB, Available: ${free_kb}KB. Sync skipped." >> "$SOURCE_FOLDER/sync_error.log"
        afplay /System/Library/Sounds/Basso.aiff
        continue
      fi

      echo "[$(timestamp)] Enough space. Starting rsync..." >> "$LOGFILE"

      mkdir -p "$DEST"

      rsync -av --delete \
        --exclude='.Trashes' \
        --exclude='.Spotlight-V100' \
        --exclude='.DS_Store' \
        "$SOURCE_FOLDER" "$DEST/" | tee -a "$LOGFILE"

      afplay /System/Library/Sounds/Glass.aiff
      echo "[$(timestamp)] Sync to '$name' complete." >> "$LOGFILE"

      echo "[$(timestamp)] Waiting 5 seconds before eject..." >> "$LOGFILE"
      sleep 5

      sync
      diskutil eject "$disk"
      afplay /System/Library/Sounds/Ping.aiff
      echo "[$(timestamp)] USB '$name' ejected." >> "$LOGFILE"
    fi
  done
done