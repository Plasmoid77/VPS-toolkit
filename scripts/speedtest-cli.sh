#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

apt-get update
apt-get install -y curl
# Packagecloud's official installer script, unpinned (curl | bash, no checksum).
curl -fsSL https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
apt-get install -y speedtest
speedtest --accept-license --accept-gdpr

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' Ookla Speedtest CLI completed successfully.' \
    '============================================================'
