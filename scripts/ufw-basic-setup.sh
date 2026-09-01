#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

ufw default deny incoming
ufw default allow outgoing
ufw --force enable
ufw status numbered

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' Basic UFW firewall configured successfully.' \
    '============================================================'
