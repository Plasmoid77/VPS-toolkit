#!/usr/bin/env bash
set -e

# Определяем, нужен ли sudo
if [ "$(id -u)" -eq 0 ]; then
    SUDO=()
else
    SUDO=(sudo)
fi

CONFIG_FILE="/etc/sysctl.d/99-bbr-vps-toolkit.conf"

# Пытаемся загрузить модуль BBR, если он доступен как модуль
"${SUDO[@]}" modprobe tcp_bbr 2>/dev/null || true

# Проверяем, доступен ли BBR в текущем ядре
AVAILABLE_CC="$("${SUDO[@]}" sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null || true)"

if ! echo "$AVAILABLE_CC" | grep -qw "bbr"; then
    echo "BBR is not available in this kernel."
    echo "Available congestion controls: ${AVAILABLE_CC:-unknown}"
    exit 1
fi

# Сохраняем текущие значения перед изменением
OLD_QDISC="$("${SUDO[@]}" sysctl -n net.core.default_qdisc 2>/dev/null || echo "unknown")"
OLD_CC="$("${SUDO[@]}" sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "unknown")"

# Комментируем активные конфликтующие настройки в /etc/sysctl.conf, если они там есть
if [ -f "/etc/sysctl.conf" ]; then
    "${SUDO[@]}" sed -i -E '/^[[:space:]]*net\.core\.default_qdisc[[:space:]]*=/ s/^/# VPS-toolkit disabled: /' /etc/sysctl.conf
    "${SUDO[@]}" sed -i -E '/^[[:space:]]*net\.ipv4\.tcp_congestion_control[[:space:]]*=/ s/^/# VPS-toolkit disabled: /' /etc/sysctl.conf
fi

# Создаём отдельный sysctl-конфиг для BBR
{
    echo "# Previous settings saved by VPS-toolkit: ${OLD_QDISC}:${OLD_CC}"
    echo "net.core.default_qdisc = fq"
    echo "net.ipv4.tcp_congestion_control = bbr"
} | "${SUDO[@]}" tee "$CONFIG_FILE" > /dev/null

# Применяем только наш BBR-конфиг
"${SUDO[@]}" sysctl -p "$CONFIG_FILE"

# Проверяем результат
CURRENT_QDISC="$("${SUDO[@]}" sysctl -n net.core.default_qdisc)"
CURRENT_CC="$("${SUDO[@]}" sysctl -n net.ipv4.tcp_congestion_control)"

echo
echo "Current qdisc: $CURRENT_QDISC"
echo "Current TCP congestion control: $CURRENT_CC"

if [ "$CURRENT_CC" != "bbr" ]; then
    echo "Failed to enable BBR."
    exit 1
fi

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " BBR enabled successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"