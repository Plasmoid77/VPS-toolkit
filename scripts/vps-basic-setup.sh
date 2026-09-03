#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

NEW_HOSTNAME="${1:-}"
NEW_SSH_PORT="${2:-}"

if [[ ! "$NEW_HOSTNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]] ||
   [[ ! "$NEW_SSH_PORT" =~ ^[0-9]+$ ]]; then
    echo "Usage: vps-basic-setup.sh NEW_HOSTNAME NEW_SSH_PORT" >&2
    exit 1
fi

NEW_SSH_PORT=$((10#$NEW_SSH_PORT))
if (( NEW_SSH_PORT < 1 || NEW_SSH_PORT > 65535 )); then
    echo "Usage: vps-basic-setup.sh NEW_HOSTNAME NEW_SSH_PORT" >&2
    exit 1
fi

TOOLKIT_DIR="$(mktemp -d)"
trap 'rm -rf "$TOOLKIT_DIR"' EXIT
# Trust-on-first-use: no checksum/signature check against the archive. Acceptable
# because the caller already trusts this repository enough to run it as root.
curl -fsSL https://github.com/Plasmoid77/VPS-toolkit/archive/refs/heads/main.tar.gz |
    tar -xz -C "$TOOLKIT_DIR" --strip-components=1

run_script() {
    local script="$1"
    shift
    bash "$TOOLKIT_DIR/scripts/$script" "$@"
}

run_script debian-admin-packages-install.sh
run_script hostname-change.sh "$NEW_HOSTNAME"
run_script apt-auto-upgrades.sh
run_script ssh-port-change.sh "$NEW_SSH_PORT"
run_script ufw-basic-setup.sh
run_script fail2ban-setup.sh
run_script security-check-setup.sh
run_script bbr-enable.sh

printf '\n\033[1;32m%s\n%s\n%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' Basic VPS deployment completed successfully.' \
    " Hostname: $NEW_HOSTNAME" \
    " SSH port: $NEW_SSH_PORT" \
    '============================================================'
