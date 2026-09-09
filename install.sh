#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

is_macos=0
if [ "$(uname -s)" = "Darwin" ]; then
    is_macos=1
fi

for folder in */; do
    [ "$folder" = "install.sh/" ] && continue

    name="${folder%/}"
    if [ "$is_macos" -eq 0 ]; then
        case "$name" in
            aerospace)
                echo "→ Skipping mac-only: $name"
                continue
                ;;
            karabiner)
                echo "→ Skipping mac-only: $name"
                continue
                ;;
        esac
    fi

    echo "→ Stowing: $name"
    stow "$folder"
done

# These apps default to Application Support on macOS rather than ~/.config.
if [ "$is_macos" -eq 1 ]; then
    for app in lazygit lazydocker; do
        config_dir="$HOME/Library/Application Support/$app"
        config_file="$config_dir/config.yml"
        config_source="$PWD/$app/.config/$app/config.yml"
        mkdir -p "$config_dir"

        if [ ! -L "$config_file" ] || [ "$(readlink "$config_file")" != "$config_source" ]; then
            if [ -e "$config_file" ] || [ -L "$config_file" ]; then
                backup_dir="$(mktemp -d "$config_dir/config-backup.XXXXXX")"
                mv "$config_file" "$backup_dir/config.yml"
                echo "→ Backed up $app config: $backup_dir/config.yml"
            fi
            ln -s "$config_source" "$config_file"
            echo "→ Linked macOS $app config"
        fi
    done
fi
