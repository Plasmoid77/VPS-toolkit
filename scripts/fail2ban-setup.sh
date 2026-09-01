#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

apt-get update
apt-get install -y fail2ban

SSH_PORTS="$(sshd -T | awk '$1 == "port" {print $2}' | sort -nu | paste -sd, -)"

cat > /etc/fail2ban/jail.d/sshd.local <<EOF
[sshd]
enabled = true
port = $SSH_PORTS
backend = systemd
bantime = 1h
findtime = 10m
maxretry = 3
EOF

fail2ban-client -t
systemctl enable fail2ban
systemctl restart fail2ban

for _ in {1..10}; do
    fail2ban-client ping >/dev/null 2>&1 && break
    sleep 1
done

fail2ban-client status sshd

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' Fail2Ban SSH protection configured successfully.' \
    '============================================================'
