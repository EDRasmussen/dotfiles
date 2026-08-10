#!/usr/bin/env bash
set -euo pipefail

ARG="${1:-}"

has_external() {
  hyprctl -j monitors | jq -e '.[] | select(.name!="eDP-1")' >/dev/null
}

enable_edp() {
  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5, disabled = false })'
}

disable_edp() {
  hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
}

scale_4k_externals() {
  hyprctl -j monitors \
    | jq -r '.[] | select(.name!="eDP-1" and .width>=3800 and .height>=2100) | .name' \
    | while read -r name; do
        # A fixed origin prevents the output (and Noctalia's layer surface)
        # from shifting when eDP-1 is disabled in clamshell mode.
        [ -n "${name:-}" ] && hyprctl eval "hl.monitor({ output = \"${name}\", mode = \"preferred\", position = \"0x0\", scale = 1.5 })"
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
      # No external display: lid shut means sleep. systemd-logind owns the
      # suspend (HandleLidSwitch=suspend, HandleLidSwitchDocked=ignore). Lock
      # first so we resume to the Noctalia lockscreen. Best-effort: this runs
      # concurrently with logind's suspend, so ordering isn't guaranteed here
      # (the 'removed' branch below owns the order and is race-free).
      loginctl lock-session
    fi
    ;;
  rescan)
    scale_4k_externals
    ;;
  removed)
    # Last external display unplugged. Make sure we never end up with no usable
    # display: re-enable the internal panel if the lid is open; if it's shut and
    # nothing external remains, suspend (logind's lid handler won't re-fire on a
    # dock change, so cover that one edge here).
    if ! has_external; then
      if grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null; then
        loginctl lock-session   # race-free: we own the order (lock, then suspend)
        systemctl suspend
      else
        enable_edp
      fi
    fi
    ;;
esac
