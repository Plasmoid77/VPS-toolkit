#!/usr/bin/env bash
set -e

# Определяем, нужен ли sudo
if [ "$(id -u)" -eq 0 ]; then
    SUDO=()
else
    SUDO=(sudo)
fi

NEW_SSH_PORT="${1:-}"

# Проверяем, что порт передан
if [ -z "$NEW_SSH_PORT" ]; then
    echo "Usage: ssh-port-change.sh NEW_SSH_PORT"
    echo "Example: ssh-port-change.sh xXxXx"
    exit 1
fi

# Проверяем, что порт является числом от 1 до 65535
if ! echo "$NEW_SSH_PORT" | grep -Eq '^[0-9]+$' || [ "$NEW_SSH_PORT" -lt 1 ] || [ "$NEW_SSH_PORT" -gt 65535 ]; then
    echo "Invalid SSH port: $NEW_SSH_PORT"
    echo "Use a number from 1 to 65535."
    exit 1
fi

SSH_CONFIG="/etc/ssh/sshd_config"
SSH_CONFIG_DIR="/etc/ssh/sshd_config.d"
SSH_PORT_CONFIG="${SSH_CONFIG_DIR}/99-vps-toolkit-port.conf"
BACKUP_DIR="/etc/ssh/vps-toolkit-backups/$(date +%F-%H%M%S)"

# Создаём backup SSH-конфигурации
"${SUDO[@]}" mkdir -p "$BACKUP_DIR"
"${SUDO[@]}" cp "$SSH_CONFIG" "$BACKUP_DIR/sshd_config"

if [ -d "$SSH_CONFIG_DIR" ]; then
    "${SUDO[@]}" cp -a "$SSH_CONFIG_DIR" "$BACKUP_DIR/sshd_config.d"
fi

# Открываем новый SSH-порт в UFW с комментарием
if command -v ufw >/dev/null 2>&1; then
    "${SUDO[@]}" ufw allow proto tcp to any port "$NEW_SSH_PORT" comment "VPS-toolkit SSH port"
fi

# Создаём директорию для drop-in SSH-конфигов
"${SUDO[@]}" mkdir -p "$SSH_CONFIG_DIR"

# Комментируем старые активные Port-строки, чтобы SSH слушал только новый порт
for file in "$SSH_CONFIG" "$SSH_CONFIG_DIR"/*.conf; do
    [ -f "$file" ] || continue
    [ "$file" = "$SSH_PORT_CONFIG" ] && continue

    "${SUDO[@]}" sed -i -E '/^[[:space:]]*Port[[:space:]]+[0-9]+/ s/^/# VPS-toolkit disabled: /' "$file"
done

# Создаём отдельный SSH-конфиг с новым портом
{
    echo "# Managed by VPS-toolkit"
    echo "Port $NEW_SSH_PORT"
} | "${SUDO[@]}" tee "$SSH_PORT_CONFIG" > /dev/null

# Проверяем SSH-конфигурацию перед применением
"${SUDO[@]}" sshd -t

# Перезагружаем SSH без разрыва текущей сессии
"${SUDO[@]}" systemctl reload ssh 2>/dev/null || \
"${SUDO[@]}" systemctl reload sshd 2>/dev/null || \
"${SUDO[@]}" service ssh reload 2>/dev/null || \
"${SUDO[@]}" service sshd reload

# Если есть локальный Fail2Ban-конфиг для SSH, обновляем в нём порт
if [ -f "/etc/fail2ban/jail.d/sshd.local" ]; then
    "${SUDO[@]}" sed -i -E "s|^[[:space:]]*port[[:space:]]*=.*|port = ${NEW_SSH_PORT}  ; SSH port managed by VPS-toolkit|" /etc/fail2ban/jail.d/sshd.local

    if command -v fail2ban-client >/dev/null 2>&1; then
        "${SUDO[@]}" fail2ban-client -t
        "${SUDO[@]}" systemctl restart fail2ban
    fi
fi

# Показываем эффективные SSH-порты
echo
echo "Effective SSH port(s):"
"${SUDO[@]}" sshd -T 2>/dev/null | awk '$1 == "port" {print "  " $2}'

# Проверяем, слушает ли sshd новый порт
echo
echo "SSH listener check:"
ss -tuln | grep ":${NEW_SSH_PORT} " || true

# Показываем UFW-статус
if command -v ufw >/dev/null 2>&1; then
    echo
    "${SUDO[@]}" ufw status numbered
fi

echo
printf '\033[1;32m%s\033[0m\n' "============================================================"
printf '\033[1;32m%s\033[0m\n' " SSH port changed successfully to: ${NEW_SSH_PORT}"
printf '\033[1;32m%s\033[0m\n' " Keep this session open and test a new SSH login first."
printf '\033[1;32m%s\033[0m\n' "============================================================"
