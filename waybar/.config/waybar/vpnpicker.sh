#!/usr/bin/env bash
set -euo pipefail

command -v nmcli >/dev/null || { echo "nmcli not found"; exit 1; }
command -v fzf   >/dev/null || { echo "fzf not found"; exit 1; }

# Get all VPN-ish connections
mapfile -t all < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wireguard" || $2=="vpn" {print $1}')

[[ ${#all[@]} -eq 0 ]] && { echo "No VPN connections found."; exit 0; }

# Get active VPN-ish connections (as a set)
active="$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="wireguard" || $2=="vpn" {print $1}')"

is_active() {
  local name="$1"
  grep -Fxq "$name" <<<"$active"
}

# Build display list
items=()
for name in "${all[@]}"; do
  if is_active "$name"; then
    items+=("$name (Connected)")
  else
    items+=("$name")
  fi
done

choice="$(printf '%s\n' "${items[@]}" | fzf --prompt="VPN > " --height=15 --border --no-multi)"
[[ -z "${choice}" ]] && exit 0

# Strip suffix
vpn="${choice% (Connected)}"

# Refresh active state right before toggling (in case it changed)
if nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="wireguard" || $2=="vpn" {print $1}' | grep -Fxq "$vpn"; then
  nmcli connection down "$vpn"
else
  nmcli connection up "$vpn"
fi
