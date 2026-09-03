#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

WORKDIR=/root/rustdeskdocker
install -d "$WORKDIR"
cd "$WORKDIR"

cat > docker-compose.yml <<'EOF'
services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    volumes:
      - ./data:/root
    network_mode: host
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./data:/root
    network_mode: host
    restart: unless-stopped
EOF

ufw allow 21115:21117/tcp comment 'RustDesk NAT test, ID registry and relay'
ufw allow 21116/udp comment 'RustDesk hole punching'
docker compose up -d

for _ in {1..30}; do
    [ -s data/id_ed25519.pub ] && break
    sleep 1
done

[ -s data/id_ed25519.pub ] || { docker compose logs; exit 1; }
docker compose ps
printf '\nRustDesk server public key:\n%s\n' "$(<data/id_ed25519.pub)"

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' RustDesk Server deployed successfully.' \
    '============================================================'
