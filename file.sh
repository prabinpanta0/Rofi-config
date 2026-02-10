#!/bin/bash

# 1. Instant selection using the info slot
if [ -n "$ROFI_INFO" ]; then
    nohup xdg-open "$ROFI_INFO" >/dev/null 2>&1 &
    exit 0
fi

# 2. Optimized variables
FD_BIN=$(command -v fd || command -v fdfind)
QUERY="${1:-""}"

EXCLUDES=(--exclude ".local" --exclude ".cache" --exclude ".git" --exclude "node_modules")

# 3. Fast List Generation
# We only process the first 500 results to keep it snappy
"$FD_BIN" --max-results 500 --max-depth 4 "${EXCLUDES[@]}" "$QUERY" "$HOME" | while read -r path; do
    name=$(basename "$path")
    display_path=${path/#$HOME/~}
    
    # Simple icon logic
    icon="text-x-generic"
    [[ -d "$path" ]] && icon="folder"
    [[ "$path" =~ \.(png|jpg|jpeg|gif)$ ]] && icon="image-x-generic"
    [[ "$path" =~ \.(mp4|mkv|avi)$ ]] && icon="video-x-generic"
    [[ "$path" =~ \.(pdf)$ ]] && icon="document-pdf"
    [[ "$path" =~ \.(zip|tar|gz)$ ]] && icon="package-x-generic"

    # Print for Rofi: Display Text \0 Metadata
    printf "%-30s  <%s>\0icon\x1f%s\x1finfo\x1f%s\n" "$name" "$display_path" "$icon" "$path"
done