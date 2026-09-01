#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

NEW_HOSTNAME="${1:-}"

if [[ ! "$NEW_HOSTNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]]; then
    echo "Usage: hostname-change.sh NEW_HOSTNAME" >&2
    exit 1
fi

sed -i "s/^127\.0\.1\.1[[:space:]].*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts
grep -q '^127\.0\.1\.1[[:space:]]' /etc/hosts || echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
hostnamectl set-hostname "$NEW_HOSTNAME"

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    " Hostname changed successfully to $NEW_HOSTNAME." \
    '============================================================'
