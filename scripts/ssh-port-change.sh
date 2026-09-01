#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

NEW_SSH_PORT="${1:-}"

if [[ ! "$NEW_SSH_PORT" =~ ^[0-9]+$ ]]; then
    echo "Usage: ssh-port-change.sh PORT" >&2
    exit 1
fi

NEW_SSH_PORT=$((10#$NEW_SSH_PORT))
if (( NEW_SSH_PORT < 1 || NEW_SSH_PORT > 65535 )); then
    echo "Usage: ssh-port-change.sh PORT" >&2
    exit 1
fi

SSH_CONFIG=/etc/ssh/sshd_config
SSH_CONFIG_DIR=/etc/ssh/sshd_config.d
SSH_PORT_CONFIG=$SSH_CONFIG_DIR/99-vps-toolkit-port.conf
PORT_CONFIG_EXISTED=0

mkdir -p /etc/ssh/vps-toolkit-backups
BACKUP_DIR="$(mktemp -d "/etc/ssh/vps-toolkit-backups/$(date +%F-%H%M%S).XXXXXX")"

restore_config() {
    cp -a "$BACKUP_DIR/sshd_config" "$SSH_CONFIG"
    [ ! -d "$BACKUP_DIR/sshd_config.d" ] || cp -a "$BACKUP_DIR/sshd_config.d/." "$SSH_CONFIG_DIR/"
    [ "$PORT_CONFIG_EXISTED" -eq 1 ] || rm -f "$SSH_PORT_CONFIG"
}

[ -e "$SSH_PORT_CONFIG" ] && PORT_CONFIG_EXISTED=1
cp -a "$SSH_CONFIG" "$BACKUP_DIR/sshd_config"
[ ! -d "$SSH_CONFIG_DIR" ] || cp -a "$SSH_CONFIG_DIR" "$BACKUP_DIR/sshd_config.d"
mkdir -p "$SSH_CONFIG_DIR"

grep -Eq '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/\*\.conf' "$SSH_CONFIG" || \
    sed -i '1iInclude /etc/ssh/sshd_config.d/*.conf' "$SSH_CONFIG"

for file in "$SSH_CONFIG" "$SSH_CONFIG_DIR"/*.conf; do
    [ -f "$file" ] || continue
    [ "$file" = "$SSH_PORT_CONFIG" ] && continue
    sed -i -E '/^[[:space:]]*Port[[:space:]]+[0-9]+/ s/^/# VPS-toolkit disabled: /' "$file"
done

printf '# Managed by VPS-toolkit\nPort %s\n' "$NEW_SSH_PORT" > "$SSH_PORT_CONFIG"

if ! sshd -t; then
    restore_config
    echo "Invalid SSH configuration; original files restored." >&2
    exit 1
fi

if command -v ufw >/dev/null 2>&1; then
    ufw limit "$NEW_SSH_PORT/tcp" comment 'SSH brute-force protection'
fi

if ! systemctl reload ssh; then
    restore_config
    if sshd -t; then
        systemctl reload ssh || true
    fi
    echo "SSH reload failed; original files restored." >&2
    exit 1
fi

if [ -f /etc/fail2ban/jail.d/sshd.local ]; then
    sed -i -E "s|^[[:space:]]*port[[:space:]]*=.*|port = $NEW_SSH_PORT|" /etc/fail2ban/jail.d/sshd.local
    fail2ban-client -t
    systemctl restart fail2ban
fi

sshd -T | awk '$1 == "port" {print "Effective SSH port: " $2}'

printf '\n\033[1;32m%s\n%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    " SSH port changed successfully to $NEW_SSH_PORT." \
    ' Keep this session open and test a new SSH login.' \
    '============================================================'
