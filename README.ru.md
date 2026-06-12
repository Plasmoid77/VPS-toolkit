# VPS-toolkit

[English](README.md)

Небольшой набор Bash-скриптов для быстрой настройки VPS, базового hardening, мониторинга и self-hosted сервисов.

## Скрипты

| Скрипт | Назначение |
|---|---|
| `apt-auto-upgrades.sh` | Настраивает автоматические security-обновления APT |
| `bbr-enable.sh` | Включает TCP congestion control BBR |
| `bbr-disable.sh` | Отключает BBR и восстанавливает не-BBR режим |
| `debian-admin-packages-install.sh` | Устанавливает расширенный админский набор пакетов для Debian |
| `docker-debian-setup.sh` | Устанавливает Docker Engine и Docker Compose plugin на Debian |
| `fail2ban-setup.sh` | Устанавливает и настраивает Fail2Ban для SSH |
| `hostname-change.sh` | Меняет hostname и обновляет `/etc/hosts` |
| `ip-quality-check.sh` | Проверяет качество и репутацию IP-адреса |
| `rustdesk-server-setup.sh` | Разворачивает RustDesk Server через Docker Compose |
| `security-check-setup.sh` | Устанавливает ежедневный SSH/security мониторинг с логами |
| `speedtest-cli.sh` | Устанавливает и запускает Ookla Speedtest CLI |
| `ufw-disable-ping.sh` | Отключает входящий ping через UFW |
| `ufw-enable-ping.sh` | Включает входящий ping обратно через UFW |

## Использование

Замени `SCRIPT_NAME.sh` на нужный скрипт:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Пример:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/fail2ban-setup.sh | sudo bash
```

## Debian admin packages

Установить расширенный админский набор пакетов для свежего Debian VPS:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/debian-admin-packages-install.sh | sudo bash
```

Набор пакетов:

| Пакет | Назначение |
|---|---|
| `sudo` | Запуск команд с повышенными правами |
| `curl` | Загрузка скриптов и HTTP-запросы |
| `ca-certificates` | Поддержка HTTPS-сертификатов |
| `gnupg` | GPG-ключи для внешних репозиториев |
| `git` | Работа с Git, Codeberg и GitHub |
| `nano` | Простой терминальный редактор |
| `less` | Удобный просмотр логов и текстовых файлов |
| `cron` | Планировщик задач |
| `ufw` | Firewall |
| `fail2ban` | Защита SSH от перебора |
| `unattended-upgrades` | Автоматические security-обновления |
| `apt-listchanges` | Просмотр изменений пакетов при обновлениях |
| `lsof` | Диагностика открытых файлов и портов |
| `jq` | Обработка JSON |
| `dnsutils` | DNS-инструменты: `dig`, `nslookup` |
| `netcat-openbsd` | Утилита `nc` для проверки портов |
| `socat` | Продвинутая сетевая утилита для сокетов |
| `htop` | Интерактивный просмотр процессов |
| `rsync` | Копирование и синхронизация файлов |
| `fastfetch` | Краткая информация о системе |
| `ranger` | Терминальный файловый менеджер |

## Смена hostname

Скрипт смены hostname требует аргумент:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
```

## Fail2Ban

Проверить созданный SSH jail config:

```bash
sudo cat /etc/fail2ban/jail.d/sshd.local
```

Что делает конфигурация:

| Параметр | Значение |
|---|---|
| `bantime = 3600` | Банит IP на 1 час |
| `findtime = 600` | Смотрит неудачные попытки за последние 10 минут |
| `maxretry = 3` | Банит после 3 неудачных попыток |
| `port = auto` | Берёт текущий SSH-порт из `sshd`, например `41337` |
| `backend = systemd` | Читает SSH-логи через `journalctl`, без привязки к `/var/log/auth.log` |

## BBR

Включить TCP congestion control BBR:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/bbr-enable.sh | sudo bash
```

Отключить BBR и восстановить не-BBR режим:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/bbr-disable.sh | sudo bash
```

Проверить текущий TCP congestion control и qdisc:

```bash
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc
```

## APT auto-upgrades

Посмотреть лог автообновлений:

```bash
sudo less /var/log/unattended-upgrades/unattended-upgrades.log
```

Выйти из просмотра:

```text
q
```

## Security check

Установить ежедневный мониторинг:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/security-check-setup.sh | sudo bash
```

Ручной прогон в терминале:

```bash
sudo /usr/local/bin/security-check.sh
```

Ручной прогон с записью в лог:

```bash
sudo /usr/local/bin/security-check.sh >> /var/log/security-check.log 2>&1
sudo tail -n 100 /var/log/security-check.log
```

Посмотреть лог:

```bash
sudo less /var/log/security-check.log
```

## RustDesk Server

Скрипт RustDesk открывает только минимально необходимые порты.

Если нужна поддержка web clients, добавь эти UFW-правила:

```bash
sudo ufw allow 21118/tcp   # RustDesk web client support for hbbs
sudo ufw allow 21119/tcp   # RustDesk web client support for hbbr
```

## Запуск скриптов

```bash
# Установить расширенный админский набор пакетов для Debian
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/debian-admin-packages-install.sh | sudo bash

# Настроить автоматические security-обновления APT
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/apt-auto-upgrades.sh | sudo bash

# Включить TCP congestion control BBR
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/bbr-enable.sh | sudo bash

# Отключить TCP congestion control BBR
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/bbr-disable.sh | sudo bash

# Установить Docker Engine и Docker Compose plugin на Debian
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/docker-debian-setup.sh | sudo bash

# Установить и настроить Fail2Ban для SSH
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/fail2ban-setup.sh | sudo bash

# Сменить hostname и обновить /etc/hosts
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee

# Проверить качество и репутацию IP-адреса
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ip-quality-check.sh | sudo bash

# Развернуть RustDesk Server через Docker Compose
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/rustdesk-server-setup.sh | sudo bash

# Установить ежедневный SSH/security мониторинг с логами
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/security-check-setup.sh | sudo bash

# Установить и запустить Ookla Speedtest CLI
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/speedtest-cli.sh | sudo bash

# Отключить входящий ping через UFW
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-disable-ping.sh | sudo bash

# Включить входящий ping обратно через UFW
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-enable-ping.sh | sudo bash
```

## Примечания

Скрипты рассчитаны на Debian-based VPS.
