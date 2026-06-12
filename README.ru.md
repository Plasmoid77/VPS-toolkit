# VPS-toolkit

[English](README.md)

Небольшой набор Bash-скриптов для быстрой настройки VPS, базового hardening, мониторинга и self-hosted сервисов.

## Скрипты

| Скрипт | Назначение |
|---|---|
| `apt-auto-upgrades.sh` | Настраивает автоматические security-обновления APT |
| `debian-admin-packages-install.sh` | Устанавливает расширенный админский набор пакетов для Debian |
| `docker-debian-setup.sh` | Устанавливает Docker Engine и Docker Compose plugin на Debian |
| `fail2ban-setup.sh` | Устанавливает и настраивает Fail2Ban для SSH |
| `hostname-change.sh` | Меняет hostname и обновляет `/etc/hosts` |
| `ip-quality-check.sh` | Проверяет качество и репутацию IP-адреса |
| `rustdesk-server-setup.sh` | Разворачивает RustDesk Server через Docker Compose |
| `security-check-setup.sh` | Устанавливает ежедневный SSH/security мониторинг с логами |
| `speedtest-cli.sh` | Устанавливает и запускает Ookla Speedtest CLI |
| `ssh-port-change.sh` | Меняет SSH-порт, добавляет UFW limit-правило и обновляет Fail2Ban |
| `ufw-basic-setup.sh` | Применяет минимальные правила UFW и включает firewall |
| `ufw-disable-ping.sh` | Отключает входящий ping через UFW |
| `ufw-enable-ping.sh` | Включает входящий ping обратно через UFW |
| `vps-basic-setup.sh` | Запускает полный базовый деплой VPS одной командой |

## Использование

Замени `SCRIPT_NAME.sh` на нужный скрипт:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Пример:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/fail2ban-setup.sh | sudo bash
```

## Быстрый базовый деплой VPS

Скрипт быстрого старта запускает полный базовый деплой нового Debian VPS.

Он принимает два аргумента:

| Аргумент | Значение | Пример |
|---|---|---|
| `NEW_HOSTNAME` | Желаемое имя хоста | `ordinary-coffee` |
| `NEW_SSH_PORT` | Желаемый SSH-порт | `41337` |

Запуск:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

Что запускает скрипт:

| Порядок | Скрипт | Действие |
|---:|---|---|
| 1 | `debian-admin-packages-install.sh` | Устанавливает базовый админский набор пакетов Debian |
| 2 | `hostname-change.sh` | Меняет hostname и обновляет `/etc/hosts` |
| 3 | `apt-auto-upgrades.sh` | Включает автоматические security-обновления APT |
| 4 | `ssh-port-change.sh` | Меняет SSH-порт и добавляет UFW `LIMIT`-правило |
| 5 | `ufw-basic-setup.sh` | Применяет минимальные правила UFW и включает firewall |
| 6 | `fail2ban-setup.sh` | Устанавливает и настраивает Fail2Ban для SSH |
| 7 | `security-check-setup.sh` | Устанавливает ежедневный SSH/security мониторинг |
| 8 | `bbr-enable.sh` | Включает TCP congestion control BBR |
| 9 | `ufw-disable-ping.sh` | Отключает входящий ping |

Этот скрипт рассчитан на быстрый доверенный первичный сетап, когда базовый порядок деплоя уже известен и проверен. После завершения нужно подключаться по новому SSH-порту.

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

## Смена SSH-порта

Скрипт смены SSH-порта требует номер порта как аргумент:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

Что делает скрипт:

| Шаг | Действие |
|---|---|
| Проверка порта | Проверяет, что аргумент является портом от `1` до `65535` |
| Backup | Сохраняет backup SSH-конфигов в `/etc/ssh/vps-toolkit-backups/` |
| SSH config | Записывает новый порт в `/etc/ssh/sshd_config.d/99-vps-toolkit-port.conf` |
| Main config | Добавляет `Include /etc/ssh/sshd_config.d/*.conf` в `/etc/ssh/sshd_config`, если его нет |
| Старые Port-строки | Комментирует активные старые строки `Port` в SSH-конфигах |
| UFW | Добавляет `LIMIT`-правило для нового SSH-порта с комментом `SSH with basic brutforce protection` |
| Проверка | Выполняет `sshd -t` перед применением |
| Reload | Перезагружает SSH без закрытия текущей сессии |
| Fail2Ban | Обновляет `/etc/fail2ban/jail.d/sshd.local`, если файл существует |

После запуска не закрывай текущую SSH-сессию и проверь новый вход из другого терминала:

```bash
ssh root@SERVER_IP -p 41337
```

Скрипт не удаляет старые UFW-правила автоматически.

## Базовая настройка UFW

Скрипт базовой настройки UFW применяет минимальные firewall defaults и включает UFW:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-basic-setup.sh | sudo bash
```

Запускай его только после того, как SSH-доступ уже разрешён: через `ssh-port-change.sh` или вручную:

| Условие | Зачем это нужно |
|---|---|
| `ssh-port-change.sh` уже выполнен, или SSH-порт открыт вручную | Так UFW не заблокирует SSH-доступ после включения firewall |
| Новый SSH-вход проверен из другого терминала | Это подтверждает, что SSH-порт доступен |
| Нужные сервисные порты уже открыты | Иначе UFW может заблокировать нужные сервисы |

Что делает скрипт:

| Шаг | Действие |
|---|---|
| Incoming policy | Выполняет `sudo ufw default deny incoming` |
| Outgoing policy | Выполняет `sudo ufw default allow outgoing` |
| Enable firewall | Выполняет `sudo ufw --force enable` |
| Status check | Показывает `sudo ufw status numbered` |

Не запускай этот скрипт до того, как SSH-порт разрешён и проверен, иначе можно потерять доступ к серверу.

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
# Запустить полный базовый деплой VPS одной командой
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337

# Установить расширенный админский набор пакетов для Debian
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/debian-admin-packages-install.sh | sudo bash

# Настроить автоматические security-обновления APT
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/apt-auto-upgrades.sh | sudo bash

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

# Сменить SSH-порт, добавить UFW limit-правило и обновить Fail2Ban
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337

# Применить минимальные правила UFW и включить firewall
# Запускать только после ssh-port-change.sh или после ручного открытия и проверки SSH-порта
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-basic-setup.sh | sudo bash

# Отключить входящий ping через UFW
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-disable-ping.sh | sudo bash

# Включить входящий ping обратно через UFW
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-enable-ping.sh | sudo bash
```

## Примечания

Скрипты рассчитаны на Debian-based VPS.
