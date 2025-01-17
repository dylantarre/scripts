#!/bin/bash

FOLDER="/Users/dylantarre/dev/playground"

# Check if any files were modified or created in the last 24 hours
if [ -z "$(find "$FOLDER" -mindepth 1 -mtime -1)" ]; then
    echo "No changes in the last 24 hours. Deleting contents..."
    rm -rf "$FOLDER"/*
else
    echo "Changes detected in the last 24 hours. Keeping contents."
fi
