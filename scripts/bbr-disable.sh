#!/usr/bin/env bash
set -e

# Определяем, нужен ли sudo
if [ "$(id -u)" -eq 0 ]; then
    SUDO=()
else
    SUDO=(sudo)
fi

CONFIG_FILE="/etc/sysctl.d/99-bbr-vps-toolkit.conf"

# Значения по умолчанию для отключения BBR
FALLBACK_QDISC="fq_codel"
AVAILABLE_CC="$("${SUDO[@]}" sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null || true)"

if echo "$AVAILABLE_CC" | grep -qw "cubic"; then
    FALLBACK_CC="cubic"
else
    FALLBACK_CC="$(for cc in $AVAILABLE_CC; do [ "$cc" != "bbr" ] && echo "$cc" && break; done)"
fi

if [ -z "$FALLBACK_CC" ]; then
    echo "No non-BBR TCP congestion control is available."
    echo "Available congestion controls: ${AVAILABLE_CC:-unknown}"
    exit 1
fi

RESTORE_QDISC="$FALLBACK_QDISC"
RESTORE_CC="$FALLBACK_CC"

# Если BBR был включён через VPS-toolkit, пытаемся восстановить старые значения
if [ -f "$CONFIG_FILE" ]; then
    FIRST_LINE="$("${SUDO[@]}" head -n 1 "$CONFIG_FILE" 2>/dev/null || true)"
    SAVED_VALUES="$(printf '%s\n' "$FIRST_LINE" | sed -n 's/^# Previous settings saved by VPS-toolkit: //p')"

    if [ -n "$SAVED_VALUES" ] && echo "$SAVED_VALUES" | grep -q ":"; then
        OLD_QDISC="${SAVED_VALUES%%:*}"
        OLD_CC="${SAVED_VALUES#*:}"

        if [ -n "$OLD_QDISC" ] && [ "$OLD_QDISC" != "unknown" ]; then
            RESTORE_QDISC="$OLD_QDISC"
        fi

        if [ -n "$OLD_CC" ] && [ "$OLD_CC" != "unknown" ] && [ "$OLD_CC" != "bbr" ]; then
            RESTORE_CC="$OLD_CC"
        fi
    fi
fi

# Если сохранённый congestion control недоступен или это снова BBR — используем fallback
if ! echo "$AVAILABLE_CC" | grep -qw "$RESTORE_CC" || [ "$RESTORE_CC" = "bbr" ]; then
    RESTORE_CC="$FALLBACK_CC"
fi

# Комментируем активную BBR-настройку в /etc/sysctl.conf, если она там есть
if [ -f "/etc/sysctl.conf" ]; then
    "${SUDO[@]}" sed -i -E '/^[[:space:]]*net\.ipv4\.tcp_congestion_control[[:space:]]*=[[:space:]]*bbr/ s/^/# VPS-toolkit disabled: /' /etc/sysctl.conf
fi

write_restore_config() {
    {
        echo "# BBR disabled/restored by VPS-toolkit"
        echo "net.core.default_qdisc = ${RESTORE_QDISC}"
        echo "net.ipv4.tcp_congestion_control = ${RESTORE_CC}"
    } | "${SUDO[@]}" tee "$CONFIG_FILE" > /dev/null
}

# Создаём restore-конфиг, чтобы BBR не вернулся после перезагрузки
write_restore_config

# Применяем restore-конфиг
if ! "${SUDO[@]}" sysctl -p "$CONFIG_FILE"; then
    if [ "$RESTORE_QDISC" != "pfifo_fast" ]; then
        RESTORE_QDISC="pfifo_fast"
        write_restore_config
        "${SUDO[@]}" sysctl -p "$CONFIG_FILE"
    else
        echo "Failed to apply sysctl restore config."
        exit 1
    fi
fi

# Проверяем результат
CURRENT_QDISC="$("${SUDO[@]}" sysctl -n net.core.default_qdisc)"
CURRENT_CC="$("${SUDO[@]}" sysctl -n net.ipv4.tcp_congestion_control)"

echo
echo "Current qdisc: $CURRENT_QDISC"
echo "Current TCP congestion control: $CURRENT_CC"

if [ "$CURRENT_CC" = "bbr" ]; then
    echo "Failed to disable BBR."
    exit 1
fi

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " BBR disabled successfully."
printf '\033[1;32m%s\033[0m\n' "============================================================"