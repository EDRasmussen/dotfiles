#!/usr/bin/env bash
set -euo pipefail

ARG="${1:-}"

has_external() {
  hyprctl -j monitors | jq -e '.[] | select(.name!="eDP-1")' >/dev/null
}

enable_edp() {
  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })'
}

disable_edp() {
  hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
}

scale_4k_externals() {
  hyprctl -j monitors \
    | jq -r '.[] | select(.name!="eDP-1" and .width>=3800 and .height>=2100) | .name' \
    | while read -r name; do
        [ -n "${name:-}" ] && hyprctl eval "hl.monitor({ output = \"${name}\", mode = \"preferred\", position = \"auto\", scale = 1.5 })"
      done
}

case "$ARG" in
  open|fallback)
    enable_edp
    scale_4k_externals
    ;;
  close)
    if has_external; then
      disable_edp
      scale_4k_externals
    else
      enable_edp
      systemctl hibernate
    fi
    ;;
  rescan)
    scale_4k_externals
    ;;
  removed)
    if ! has_external; then
      systemctl hibernate
    fi
    ;;
esac
