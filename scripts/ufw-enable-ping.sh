#!/usr/bin/env bash
set -e

# Разрешаем входящий IPv4 ping обратно
sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/' /etc/ufw/before.rules

# Разрешаем входящий IPv6 ping обратно
sudo sed -i 's/-A ufw6-before-input -p ipv6-icmp --icmpv6-type echo-request -j DROP/-A ufw6-before-input -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT/' /etc/ufw/before6.rules

# Перезагружаем UFW
sudo ufw reload

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " Incoming ping has been enabled successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"
