#!/usr/bin/env bash
# GuardOS System Bootstrap (Pre‑Alpha Mock)
# Simulates OS init logic in a shell‑only environment (e.g., Termux or VM)
# Later versions will translate this into initramfs logic or systemd unit structure.

set -euo pipefail

PROFILE_FILE="${1:-profiles/minimal.yaml}"
echo ">> [boot] Using profile: $PROFILE_FILE"

# Load system hostname
HOSTNAME=$(awk '/^hostname:/ { print $2; exit }' "$PROFILE_FILE")
[[ -z "$HOSTNAME" ]] && HOSTNAME="guardos"
echo ">> [boot] Setting hostname: $HOSTNAME"
hostname "$HOSTNAME" 2>/dev/null || echo "(simulated: hostname set to $HOSTNAME)"

# Setup timezone (simulated)
TZ=$(awk '/^timezone:/ { print $2; exit }' "$PROFILE_FILE")
[[ -z "$TZ" ]] && TZ="UTC"
echo ">> [boot] Setting timezone: $TZ"

# Enable services from profile
echo ">> [boot] Enabling services:"
awk '/^services:/,/[^- name:.+]/' "$PROFILE_FILE" | grep 'enabled:' | while read -r line; do
  svc=$(echo "$line" | awk '{print $2}')
  [[ "$svc" == "true" ]] && echo "   + $(grep 'name:' <<< "$line" -B1 | grep 'name:' | awk '{print $2}')"
done

# Start GuardPanel
echo ">> [boot] Launching GuardPanel..."
bash guardos/guardpanel/cli.sh show-config

echo ">> [boot] System initialized (simulated)"
