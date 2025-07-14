set -e
cd "$(dirname "$0")"

for folder in */; do
    [ "$folder" = "install.sh/" ] && continue
    echo "→ Stowing: ${folder%/}"
    stow "$folder"
done
