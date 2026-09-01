#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

CONFIG=/etc/sysctl.d/99-bbr-vps-toolkit.conf

modprobe tcp_bbr 2>/dev/null || true

cat > "$CONFIG" <<'EOF'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF

sysctl -p "$CONFIG"

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' BBR enabled successfully.' \
    '============================================================'
