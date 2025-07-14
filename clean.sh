set -e
cd "$(dirname "$0")"

for folder in */; do
    [ "$folder" = "install.sh/" ] && continue
    echo "→ Unstowing: ${folder%/}"
    stow -D "$folder"
done
