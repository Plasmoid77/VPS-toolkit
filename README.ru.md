# VPS-toolkit

[English](README.md)

Небольшие и сфокусированные Bash-скрипты для первичной настройки Debian VPS, базового hardening, мониторинга и self-hosted сервисов.

## Требования

- Debian с systemd
- root-доступ
- `curl` для запуска однострочных команд

Административные скрипты завершаются, если запущены не от root. Повышенные права не нужны только для `ip-quality-check.sh`.

## Скрипты

| Скрипт | Назначение |
|---|---|
| `apt-auto-upgrades.sh` | Настройка автоматических security-обновлений APT |
| `bbr-enable.sh` / `bbr-disable.sh` | Постоянное включение или отключение BBR |
| `debian-admin-packages-install.sh` | Установка компактного набора админских пакетов |
| `docker-debian-setup.sh` | Установка Docker Engine и Compose из репозитория Docker |
| `fail2ban-setup.sh` | Защита фактического SSH-порта через Fail2Ban |
| `hostname-change.sh` | Смена hostname и обновление `/etc/hosts` |
| `ip-quality-check.sh` | Проверка репутации IP через IP.Check.Place |
| `rustdesk-server-setup.sh` | Развёртывание RustDesk Server через Docker Compose |
| `security-check-setup.sh` | Установка ежедневного SSH/security-отчёта |
| `speedtest-cli.sh` | Установка и запуск Ookla Speedtest CLI |
| `ssh-port-change.sh` | Смена SSH-порта и обновление UFW/Fail2Ban |
| `ufw-basic-setup.sh` | Минимальные настройки UFW и включение firewall |
| `ufw-disable-ping.sh` / `ufw-enable-ping.sh` | Отключение или включение входящих ICMP echo request |
| `vps-basic-setup.sh` | Запуск базовой последовательности настройки |

## Использование

Замени `SCRIPT_NAME.sh` на нужный скрипт:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Скрипты с аргументами:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

Проверка репутации IP без root:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ip-quality-check.sh | bash
```

## Базовая настройка VPS

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

Два аргумента — новый hostname и SSH-порт. Скрипт последовательно запускает:

1. Установку админских пакетов Debian
2. Смену hostname
3. Автоматические security-обновления APT
4. Смену SSH-порта и UFW limit-правило
5. Базовый firewall UFW
6. Fail2Ban для SSH
7. Ежедневный security-отчёт
8. BBR

Не закрывай текущую SSH-сессию, пока не проверишь второй вход:

```bash
ssh root@SERVER_IP -p 41337
```

## Важные замечания

- `ssh-port-change.sh` сохраняет backup в `/etc/ssh/vps-toolkit-backups/`, проверяет конфигурацию перед reload и не удаляет старые UFW-правила.
- Запускай `ufw-basic-setup.sh` только после открытия и проверки SSH-порта. Базовый сетап соблюдает этот порядок автоматически.
- Отключение ping опционально и не входит в базовый сетап: заметного hardening оно не даёт, а диагностику ухудшает.
- Опубликованные Docker-порты могут обходить правила UFW. Перед публикацией сервисов прочитай [предупреждение Docker](https://docs.docker.com/engine/install/debian/#firewall-limitations).
- `rustdesk-server-setup.sh` требует Docker и UFW, хранит данные в `/root/rustdeskdocker` и открывает TCP `21115:21117` и UDP `21116`.
- Ежедневный отчёт записывается в `/var/log/security-check.log` в 09:00 с заменой предыдущего отчёта, поэтому лог не растёт бесконечно.

Ручной запуск и просмотр security-отчёта:

```bash
sudo /usr/local/bin/security-check.sh
sudo cat /var/log/security-check.log
```
