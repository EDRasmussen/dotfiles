#!/usr/bin/env bash
set -euo pipefail

vpn="$(nmcli -t -f NAME,TYPE connection show --active \
  | awk -F: '$2=="wireguard" || $2=="vpn" {print $1; exit}')"

if [[ -n "${vpn}" ]]; then
  echo "VPN: ${vpn}"
else
  echo ""
fi
