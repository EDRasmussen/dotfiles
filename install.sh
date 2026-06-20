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
