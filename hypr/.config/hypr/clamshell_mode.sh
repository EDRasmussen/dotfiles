#!/usr/bin/env bash
set -euo pipefail

ARG="${1:-}"
LOCK="/tmp/clamshell_lock"

debounce() {
  if [ -e "$LOCK" ] && [ $(( $(date +%s) - $(stat -c %Y "$LOCK") )) -lt 1 ]; then
    exit 0
  fi
  : > "$LOCK"
}

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

fallback_if_no_external() {
  sleep 0.15
  if ! has_external; then
    hyprctl keyword monitor "eDP-1,preferred,auto,1"
    for ws in $(seq 1 10); do hyprctl dispatch moveworkspacetomonitor "$ws eDP-1" || true; done
    hyprctl dispatch focusmonitor eDP-1 || true
  fi
}

case "$ARG" in
  open)
    debounce
    hyprctl keyword monitor "eDP-1,preferred,auto,1"
    scale_4k_externals
    ;;
  close)
    debounce
    if has_external; then
      hyprctl keyword monitor "eDP-1,disable"
      scale_4k_externals
    else
      hyprctl keyword monitor "eDP-1,preferred,auto,1"
    fi
    ;;
  rescan|scale)
    debounce
    scale_4k_externals
    ;;
  fallback)
    debounce
    fallback_if_no_external
    ;;
esac
