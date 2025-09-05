set -euo pipefail

ARG="${1:-}"

has_external() {
  hyprctl -j monitors | jq -e '.[] | select(.name!="eDP-1")' >/dev/null
}

scale_4k_externals() {
  hyprctl -j monitors \
    | jq -r '.[] | select(.name!="eDP-1" and .width>=3800 and .height>=2100) | .name' \
    | while read -r name; do
        [ -n "${name:-}" ] && hyprctl keyword monitor "${name},preferred,auto,1.5"
      done
}

case "$ARG" in
  open)
    hyprctl keyword monitor "eDP-1,preferred,auto,1"
    scale_4k_externals
    ;;
  close)
    if has_external; then
      hyprctl keyword monitor "eDP-1,disable"
      scale_4k_externals
    else
      hyprctl keyword monitor "eDP-1,preferred,auto,1"
      systemctl hibernate
    fi
    ;;
  rescan)
    scale_4k_externals
    ;;
  removed)
    if ! has_external; then
      hyprctl keyword monitor "eDP-1,preferred,auto,1"
      systemctl hibernate
    fi
    ;;
esac
