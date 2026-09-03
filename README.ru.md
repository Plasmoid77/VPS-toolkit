# VPS-toolkit

[English](README.md)

Набор сфокусированных Bash-скриптов для первичной настройки Debian VPS, базового hardening, мониторинга, сетевого тюнинга и self-hosted сервисов.

Скрипты намеренно рассчитаны на Debian с systemd. Они не пытаются угадывать дистрибутив, подбирать имена пакетов для посторонних систем или ветвиться по архитектуре процессора. Только Docker APT source читает codename Debian и пакетную архитектуру — оба значения обязательны для репозитория Docker.

## Требования и безопасность

- Debian с systemd
- root-доступ
- `curl` для однострочных команд
- действующая SSH-сессия, которую можно оставить открытой на время проверки изменений SSH/UFW

Все административные скрипты останавливаются до внесения изменений, если запущены не от root. Повышенные права не нужны только для `ip-quality-check.sh`.

Перед передачей удалённого скрипта в root Bash его можно скачать и проверить:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh -o /tmp/ssh-port-change.sh
less /tmp/ssh-port-change.sh
sudo bash /tmp/ssh-port-change.sh 41337
```

## Список скриптов

| Скрипт | Назначение |
|---|---|
| `apt-auto-upgrades.sh` | Настройка автоматических security-обновлений APT |
| `bbr-enable.sh` | Постоянное включение BBR и очереди `fq` |
| `bbr-disable.sh` | Постоянное переключение на `cubic` и `fq_codel` |
| `debian-admin-packages-install.sh` | Установка компактного набора админских пакетов Debian |
| `docker-debian-setup.sh` | Установка Docker Engine и Compose из официального репозитория |
| `fail2ban-setup.sh` | Защита фактического SSH-порта через Fail2Ban |
| `hostname-change.sh` | Смена hostname и обновление `/etc/hosts` |
| `ip-quality-check.sh` | Проверка репутации IP через IP.Check.Place |
| `rustdesk-server-setup.sh` | Развёртывание RustDesk Server через Docker Compose |
| `security-check-setup.sh` | Установка ежедневного SSH/security-отчёта |
| `speedtest-cli.sh` | Установка и запуск Ookla Speedtest CLI |
| `ssh-port-change.sh` | Смена SSH-порта и обновление UFW/Fail2Ban |
| `ufw-basic-setup.sh` | Минимальные настройки UFW и включение firewall |
| `ufw-disable-ping.sh` | Блокировка входящих IPv4/IPv6 echo request |
| `ufw-enable-ping.sh` | Восстановление входящих IPv4/IPv6 echo request |
| `vps-basic-setup.sh` | Полная последовательность базовой настройки |

Каждый успешно выполненный скрипт заканчивается зелёным сообщением в рамке. При ошибке строгий режим Bash останавливает выполнение до появления этой рамки.

## Общее использование

Замени `SCRIPT_NAME.sh` на нужный скрипт:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Аргументы передаются после `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

## Базовая настройка VPS

Скрипт принимает новый hostname и SSH-порт:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

Он загружает один архив репозитория, поэтому все дочерние скрипты берутся из одного snapshot, а затем выполняет:

| Порядок | Скрипт | Результат |
|---:|---|---|
| 1 | `debian-admin-packages-install.sh` | Устанавливает админские инструменты для следующих шагов |
| 2 | `hostname-change.sh` | Меняет hostname и строку `127.0.1.1` в `/etc/hosts` |
| 3 | `apt-auto-upgrades.sh` | Включает ежедневное обновление метаданных и unattended upgrades |
| 4 | `ssh-port-change.sh` | Сохраняет backup SSH, меняет порт и добавляет UFW limit-правило |
| 5 | `ufw-basic-setup.sh` | Запрещает нежелательные входящие подключения и включает UFW |
| 6 | `fail2ban-setup.sh` | Включает SSH jail на фактическом порту |
| 7 | `security-check-setup.sh` | Устанавливает ежедневный отчёт и root cron-задачу |
| 8 | `bbr-enable.sh` | Постоянно включает BBR |

Базовый деплой не устанавливает Docker/RustDesk, не запускает Speedtest/проверку IP и не отключает ping.

После завершения не закрывай текущую сессию, пока не проверишь второе подключение:

```bash
ssh root@SERVER_IP -p 41337
```

## Админские пакеты Debian

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/debian-admin-packages-install.sh | sudo bash
```

Скрипт обновляет метаданные APT и устанавливает пакеты, не обновляя целиком операционную систему:

| Пакет | Назначение |
|---|---|
| `sudo` | Контролируемое повышение прав для администраторов |
| `ca-certificates` | Проверка HTTPS-сертификатов |
| `curl` | HTTP-загрузки и API-запросы |
| `git` | Работа с системой контроля версий |
| `nano`, `less` | Редактирование и просмотр текста/логов |
| `cron` | Запланированные задачи |
| `ufw` | Firewall хоста |
| `fail2ban` | Защита от перебора |
| `unattended-upgrades`, `apt-listchanges` | Автообновления и информация об изменениях пакетов |
| `lsof` | Диагностика открытых файлов и сокетов |
| `jq` | Обработка JSON |
| `dnsutils` | `dig`, `nslookup` и другие DNS-инструменты |
| `netcat-openbsd`, `socat` | Диагностика TCP/UDP и сокетов |
| `htop` | Интерактивный просмотр процессов |
| `rsync` | Синхронизация файлов |

## Смена hostname

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
```

Аргумент должен начинаться и заканчиваться буквой или цифрой; внутри допустимы буквы, цифры, точки и дефисы. Скрипт обновляет или создаёт строку `127.0.1.1` в `/etc/hosts`, затем применяет hostname через `hostnamectl`.

```bash
hostnamectl status
grep '^127.0.1.1' /etc/hosts
```

## Автоматические security-обновления APT

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/apt-auto-upgrades.sh | sudo bash
```

Скрипт устанавливает `unattended-upgrades`, включает таймеры `apt-daily`/`apt-daily-upgrade` и создаёт:

| Файл | Настройка |
|---|---|
| `/etc/apt/apt.conf.d/20auto-upgrades` | Ежедневное обновление списков, ежедневные unattended upgrades, еженедельная очистка кэша |
| `/etc/apt/apt.conf.d/52unattended-upgrades-local` | Без автоматической перезагрузки; удаление ненужных зависимостей |

```bash
systemctl list-timers 'apt-daily*' --no-pager
sudo less /var/log/unattended-upgrades/unattended-upgrades.log
```

## Смена SSH-порта

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

Порт должен быть целым числом от `1` до `65535`. Последовательность действий:

1. Создаёт уникальный backup в `/etc/ssh/vps-toolkit-backups/`.
2. Проверяет, что `/etc/ssh/sshd_config` подключает `/etc/ssh/sshd_config.d/*.conf`.
3. Комментирует активные `Port` в основном файле и drop-in конфигурациях.
4. Создаёт `/etc/ssh/sshd_config.d/99-vps-toolkit-port.conf`.
5. Выполняет `sshd -t`; при ошибке автоматически восстанавливает исходные файлы.
6. Добавляет UFW `LIMIT`-правило, если UFW установлен.
7. Делает reload Debian-сервиса `ssh`, не завершая текущую сессию.
8. Восстанавливает backup, если reload не удался.
9. Обновляет `/etc/fail2ban/jail.d/sshd.local`, если файл существует, и перезапускает Fail2Ban.

Старые UFW-правила намеренно не удаляются. Удаляй их только после успешной проверки нового входа.

```bash
sudo sshd -T | awk '$1 == "port"'
sudo ss -ltnp
sudo ufw status numbered
```

## Базовый firewall UFW

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ufw-basic-setup.sh | sudo bash
```

Скрипт выполняет:

```text
default deny incoming
default allow outgoing
enable UFW
```

Он не угадывает и не открывает SSH-порт. Запускай его только после добавления и проверки SSH-правила. Базовый деплой выполняет операции в безопасном порядке.

## Fail2Ban для SSH

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/fail2ban-setup.sh | sudo bash
```

Фактический SSH-порт читается из `sshd -T` и записывается в `/etc/fail2ban/jail.d/sshd.local`.

| Параметр | Значение | Смысл |
|---|---:|---|
| `backend` | `systemd` | Чтение SSH-событий из journal |
| `bantime` | `1h` | Время блокировки |
| `findtime` | `10m` | Окно наблюдения |
| `maxretry` | `3` | Ошибки до блокировки |

Конфигурация проверяется до перезапуска Fail2Ban.

```bash
sudo fail2ban-client status sshd
```

## Ежедневный security-отчёт

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/security-check-setup.sh | sudo bash
```

Устанавливается `/usr/local/bin/security-check.sh`, включается cron и добавляется root-задача на `09:00`. Отчёт содержит:

- время выполнения и период наблюдения семь дней;
- фактические SSH-порты;
- количество неудачных SSH-аутентификаций из journal;
- количество доступных обновлений;
- статус SSH jail Fail2Ban;
- слушающие и установленные SSH-сокеты.

Последний отчёт заменяет `/var/log/security-check.log`, поэтому файл не растёт бесконечно. Права `0600` разрешают чтение только root.

```bash
sudo /usr/local/bin/security-check.sh
sudo cat /var/log/security-check.log
sudo crontab -l
```

## BBR

Включить BBR:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/bbr-enable.sh | sudo bash
```

Отключить BBR и использовать распространённые значения Debian:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/bbr-disable.sh | sudo bash
```

Оба скрипта управляют `/etc/sysctl.d/99-bbr-vps-toolkit.conf` и применяют только этот файл. Включение задаёт `fq` + `bbr`, отключение — `fq_codel` + `cubic`. Неподдерживаемые параметры ядра завершают скрипт с ошибкой вместо молчаливого выбора случайного fallback.

```bash
sysctl net.core.default_qdisc net.ipv4.tcp_congestion_control
```

## Docker Engine и Compose

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/docker-debian-setup.sh | sudo bash
```

Скрипт использует официальный Debian APT-метод Docker:

1. Устанавливает `ca-certificates` и `curl`.
2. Загружает ключ в `/etc/apt/keyrings/docker.asc`.
3. Создаёт `/etc/apt/sources.list.d/docker.sources` в формате Deb822.
4. Устанавливает Docker Engine, CLI, containerd, Buildx и Compose plugin.
5. Включает сервис Docker и проверяет версию сервера.

Codename Debian и архитектура `dpkg` в source-файле — обязательные селекторы репозитория, а не эвристики совместимости.

Опубликованные Docker-порты могут обходить UFW. Изучи [предупреждение Docker](https://docs.docker.com/engine/install/debian/#firewall-limitations) и используй цепочку `DOCKER-USER`, если нужна фильтрация.

```bash
sudo systemctl status docker --no-pager
sudo docker version
sudo docker compose version
```

## RustDesk Server

Требования: Docker Engine с Compose plugin и UFW.

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/rustdesk-server-setup.sh | sudo bash
```

Скрипт создаёт `/root/rustdeskdocker/docker-compose.yml`, запускает `hbbs` и `hbbr` с host networking и хранит ключи/данные в `/root/rustdeskdocker/data`.

| Порт | Протокол | Назначение |
|---:|---|---|
| `21115` | TCP | Проверка типа NAT |
| `21116` | TCP/UDP | Регистрация ID, heartbeat и hole punching |
| `21117` | TCP | Relay-сервис |

Это минимальные порты RustDesk. WebSocket-порты `21118`/`21119` не открываются. После старта скрипт ждёт появления и выводит `data/id_ed25519.pub`; этот ключ нужно настроить в клиентах RustDesk.

### Почему host networking, а не официальный compose-файл

Официальный compose-файл RustDesk помещает контейнеры в bridge-сеть и публикует порты через `ports:`. Это ровно тот случай, о котором предупреждает [документация Docker](https://docs.docker.com/engine/install/debian/#firewall-limitations) выше: Docker пишет собственные правила iptables, опубликованные порты доступны в обход UFW, и правила `ufw allow` из этого скрипта стали бы декоративными — порты были бы открыты в интернет независимо от того, разрешает их UFW или нет.

С `network_mode: host` контейнеры слушают напрямую на хосте, публикации портов через Docker не происходит, и доступ к `21115-21117` реально определяет UFW. Плата за это — контейнеры разделяют сетевое пространство имён хоста: у них нет сетевой изоляции, а порты нельзя переназначить. Для сервера, выделенного под RustDesk, размен выгодный; если нужна изоляция или другие порты, используй официальный compose-файл и фильтруй через цепочку `DOCKER-USER`, а не через UFW.

```bash
cd /root/rustdeskdocker
sudo docker compose ps
sudo docker compose logs
sudo cat data/id_ed25519.pub
```

## Ookla Speedtest

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/speedtest-cli.sh | sudo bash
```

Скрипт подключает Ookla Packagecloud, устанавливает официальный пакет `speedtest` и принимает license/GDPR для первого запуска.

## Проверка репутации IP

Root не требуется:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ip-quality-check.sh | bash
```

Обёртка загружает внешний скрипт IP.Check.Place и запускает его на английском с неинтерактивными параметрами. Перед использованием на чувствительном сервере проверь upstream-сервис.

## Входящий ping

Отключить входящие IPv4/IPv6 echo request:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ufw-disable-ping.sh | sudo bash
```

Восстановить:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ufw-enable-ping.sh | sudo bash
```

Скрипты меняют только echo-request правила в `/etc/ufw/before.rules` и `/etc/ufw/before6.rules`, проверяют ожидаемые строки и перезагружают UFW. Остальной ICMP/ICMPv6, необходимый для нормальной работы сети, не меняется.

Блокировка echo request почти не усиливает защиту и ухудшает наблюдаемость, поэтому она опциональна и исключена из базового деплоя.

## Проверка репозитория

Каждый push и pull request запускает `.github/workflows/shellcheck.yml`: все скрипты проверяются через `bash -n` и ShellCheck.

Скрипты рассчитаны на Debian VPS. Это не универсальный cross-distribution provisioning framework и не замена snapshot провайдера, проверенным backup или configuration management.

## Лицензия

GPL-3.0-or-later — см. [LICENSE](LICENSE).
