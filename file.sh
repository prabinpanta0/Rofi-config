#!/bin/bash

# 1. Instant selection using the info slot
if [ -n "$ROFI_INFO" ]; then
    nohup xdg-open "$ROFI_INFO" >/dev/null 2>&1 &
    exit 0
fi

# 2. Optimized variables
FD_BIN=$(command -v fd || command -v fdfind)
QUERY="${1:-""}"

EXCLUDES=(
    # --- Original & Core Exclusions ---
    --exclude ".local" --exclude ".cache" --exclude ".git" 
    --exclude ".mozilla" --exclude ".var" --exclude ".cargo" 
    --exclude "node_modules" --exclude ".npm" --exclude "Android"
    --exclude "go" --exclude ".rustup" --exclude "temp" --exclude "tmp" --exclude "build" 
    --exclude "venv" --exclude "__pycache__" --exclude ".vscode" --exclude "virtualenvs"
    
    # --- Desktop & Browser Bloat ---
    --exclude ".config/google-chrome" --exclude ".config/chromium"
    --exclude ".config/discord" --exclude ".config/Slack"
    --exclude ".config/microsoft-edge" --exclude ".zoom"
    --exclude "Downloads" --exclude "Desktop" # Optional: common for non-source search
    
    # --- Development & Data Science ---
    --exclude ".m2" --exclude ".ivy2"            # More Java/Maven
    --exclude ".terraform" --exclude ".terragrunt" # DevOps
    --exclude ".tox" --exclude ".pytest_cache"     # Python Testing
    --exclude ".conda" --exclude "anaconda3"       # Python Data Science
    --exclude "target"                             # Rust/Maven build output
    --exclude "dist" --exclude "out"               # Common JS/C++ build folders
    
    # --- Container & VM Noise ---
    --exclude ".docker" --exclude ".kube"
    --exclude ".minikube" --exclude ".vagrant"
    --exclude "VirtualBox\ VMs" --exclude ".colima"
    
    # --- Flatpak & Snap Junk ---
    --exclude "snap" 
    --exclude ".flatpak-info"
    
    # --- Media & Fonts ---
    --exclude ".fonts" --exclude ".icons" --exclude ".themes"
    --exclude ".thumbnail" --exclude ".thumbnails"
    
    # --- Secret & Key Storage (Security) ---
    --exclude ".ssh" --exclude ".aws"
    --exclude ".config/gcloud" --exclude "*.pem" --exclude "*.key"
    
    # --- History & Logs ---
    --exclude "*.log" --exclude ".zsh_history" --exclude ".lesshst"

    # --- Optional: Add more based on your specific needs ---
)

# 3. Fast List Generation
# We only process the first 2000  results to keep it snappy
# "$FD_BIN" --max-results 2000 --max-depth 4 "${EXCLUDES[@]}" "$QUERY" "$HOME" | while read -r path; do
#     name=$(basename "$path")
#     display_path=${path/#$HOME/~}
    
#     # Simple icon logic
#     icon="text-x-generic"
#     [[ -d "$path" ]] && icon="folder"
#     [[ "$path" =~ \.(png|jpg|jpeg|gif)$ ]] && icon="image-x-generic"
#     [[ "$path" =~ \.(mp4|mkv|avi)$ ]] && icon="video-x-generic"
#     [[ "$path" =~ \.(pdf)$ ]] && icon="document-pdf"
#     [[ "$path" =~ \.(zip|tar|gz)$ ]] && icon="package-x-generic"

#     # Print for Rofi: Display Text \0 Metadata
#     printf "%-30s  <%s>\0icon\x1f%s\x1finfo\x1f%s\n" "$name" "$display_path" "$icon" "$path"
# done

# Optimized AWK with trailing slash handling
"$FD_BIN" --max-results 2000 --max-depth 4 "${EXCLUDES[@]}" "$QUERY" "$HOME" | awk -v home="$HOME" '
{
    path = $0
    # Remove trailing slash if it exists so split() gets the folder name
    clean_path = path; sub(/\/$/, "", clean_path);
    
    display_path = path
    sub(home, "~", display_path)
    
    n = split(clean_path, parts, "/")
    name = parts[n]

    icon = "text-x-generic"
    # Improved folder detection
    if (path ~ /\/$/ || system("test -d \"" path "\"") == 0) icon = "folder"
    else if (path ~ /\.(png|jpg|jpeg|gif)$/) icon = "image-x-generic"
    else if (path ~ /\.(mp4|mkv|avi)$/) icon = "video-x-generic"
    else if (path ~ /\.(pdf)$/) icon = "document-pdf"
    else if (path ~ /\.(zip|tar|gz)$/) icon = "package-x-generic"

    printf "%-30s  <%s>\0icon\x1f%s\x1finfo\x1f%s\n", name, display_path, icon, path
}'