#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/' /etc/ufw/before.rules
sed -i 's/-A ufw6-before-input -p icmpv6 --icmpv6-type echo-request -j DROP/-A ufw6-before-input -p icmpv6 --icmpv6-type echo-request -j ACCEPT/' /etc/ufw/before6.rules
grep -Fqx -- '-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT' /etc/ufw/before.rules
grep -Fqx -- '-A ufw6-before-input -p icmpv6 --icmpv6-type echo-request -j ACCEPT' /etc/ufw/before6.rules
ufw reload

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' Incoming ping enabled successfully.' \
    '============================================================'
