#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

WORKDIR=/root/rustdeskdocker
install -d "$WORKDIR"
cd "$WORKDIR"

# Bridge network with published ports, as in RustDesk's official compose file:
# each container keeps its own network namespace, so a compromised container
# cannot reach services bound to 127.0.0.1 on the host. No UFW rules are added
# because Docker publishes these ports itself, past UFW -- and they are exactly
# the ports that must be reachable from the internet anyway. To restrict them
# to specific sources later, use the DOCKER-USER chain; UFW cannot do it.
cat > docker-compose.yml <<'EOF'
networks:
  rustdesk-net:
    external: false

services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
    volumes:
      - ./data:/root
    networks:
      - rustdesk-net
    depends_on:
      - hbbr
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    ports:
      - 21117:21117
    volumes:
      - ./data:/root
    networks:
      - rustdesk-net
    restart: unless-stopped
EOF

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
