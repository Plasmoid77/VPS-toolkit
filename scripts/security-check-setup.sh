#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

apt-get update
apt-get install -y cron
systemctl enable --now cron

cat > /usr/local/bin/security-check.sh <<'EOF'
#!/usr/bin/env bash
# No -e: this is a report, so one failing sub-command (e.g. fail2ban not
# installed) must not abort the rest of the checks.
set -uo pipefail

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SINCE='7 days ago'
SSH_PORTS="$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2}' | sort -nu)"
FAILED_SSH="$(journalctl -u ssh -u sshd --since "$SINCE" --no-pager 2>/dev/null | grep -Ec 'Failed password|Invalid user|authentication failure')"
UPDATES="$(apt list --upgradable 2>/dev/null | sed '1d' | wc -l)"

printf 'Security check: %s\nPeriod: %s\nSSH port(s):\n%s\n' "$(date --iso-8601=seconds)" "$SINCE" "$SSH_PORTS"
printf 'Failed SSH attempts: %s\nUpgradable packages: %s\n\n' "$FAILED_SSH" "$UPDATES"

echo 'Fail2Ban:'
fail2ban-client status sshd 2>&1 || true

echo
echo 'SSH sockets:'
for port in $SSH_PORTS; do
    ss -ltnp "sport = :$port" 2>/dev/null || true
    ss -tnp state established "sport = :$port" 2>/dev/null || true
done
EOF

chmod 0755 /usr/local/bin/security-check.sh
touch /var/log/security-check.log
chmod 0600 /var/log/security-check.log

CRONTAB_FILE="$(mktemp)"
trap 'rm -f "$CRONTAB_FILE"' EXIT
crontab -l 2>/dev/null | grep -Fv '/usr/local/bin/security-check.sh' > "$CRONTAB_FILE" || true
echo '0 9 * * * /usr/local/bin/security-check.sh > /var/log/security-check.log 2>&1' >> "$CRONTAB_FILE"
crontab "$CRONTAB_FILE"

/usr/local/bin/security-check.sh > /var/log/security-check.log

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' Daily security check configured successfully.' \
    '============================================================'
