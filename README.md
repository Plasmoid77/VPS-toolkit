# VPS-toolkit

[Русский](README.ru.md)

A collection of focused Bash scripts for initial Debian VPS setup, basic hardening, monitoring, network tuning and self-hosted services.

The scripts deliberately target Debian with systemd. They do not try to guess the distribution, translate package names for unrelated systems or branch on CPU architecture. The Docker APT source is the only place that reads the Debian codename and package architecture because both values are required by Docker's repository.

## Requirements and safety

- Debian with systemd
- root access
- `curl` for the remote one-line commands
- an existing SSH session that can remain open while SSH/UFW changes are tested

All administrative scripts stop before making changes unless they run as root. `ip-quality-check.sh` is the only script that does not require elevated privileges.

Before piping a remote script into root Bash, inspect it if the server or repository is not under your control:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh -o /tmp/ssh-port-change.sh
less /tmp/ssh-port-change.sh
sudo bash /tmp/ssh-port-change.sh 41337
```

## Script index

| Script | Purpose |
|---|---|
| `apt-auto-upgrades.sh` | Configure unattended APT security updates |
| `bbr-enable.sh` | Enable BBR and the `fq` queue discipline persistently |
| `bbr-disable.sh` | Switch back to `cubic` and `fq_codel` persistently |
| `debian-admin-packages-install.sh` | Install a compact Debian administration package set |
| `docker-debian-setup.sh` | Install Docker Engine and Compose from Docker's official repository |
| `fail2ban-setup.sh` | Protect the effective SSH port with Fail2Ban |
| `hostname-change.sh` | Change the hostname and update `/etc/hosts` |
| `ip-quality-check.sh` | Run the IP.Check.Place reputation test |
| `rustdesk-server-setup.sh` | Deploy RustDesk Server with Docker Compose |
| `security-check-setup.sh` | Install a daily SSH/security status report |
| `speedtest-cli.sh` | Install and run Ookla Speedtest CLI |
| `ssh-port-change.sh` | Change the SSH port and update UFW/Fail2Ban |
| `ufw-basic-setup.sh` | Apply minimal UFW defaults and enable the firewall |
| `ufw-disable-ping.sh` | Block incoming IPv4 and IPv6 echo requests |
| `ufw-enable-ping.sh` | Restore incoming IPv4 and IPv6 echo requests |
| `vps-basic-setup.sh` | Run the complete basic deployment sequence |

Every successful script ends with a green framed status message. If a command fails, strict Bash error handling stops the script before that message is printed.

## General usage

Replace `SCRIPT_NAME.sh` with the required script:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Arguments are passed after `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

## Basic VPS deployment

The basic deployment script accepts a new hostname and SSH port:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

It downloads one repository archive so every child script comes from the same snapshot, then runs:

| Order | Script | Result |
|---:|---|---|
| 1 | `debian-admin-packages-install.sh` | Installs the administration tools required by the remaining steps |
| 2 | `hostname-change.sh` | Changes the hostname and updates `127.0.1.1` in `/etc/hosts` |
| 3 | `apt-auto-upgrades.sh` | Enables daily package metadata refresh and unattended upgrades |
| 4 | `ssh-port-change.sh` | Backs up SSH configuration, changes the port and adds a UFW limit rule |
| 5 | `ufw-basic-setup.sh` | Denies unsolicited incoming traffic and enables UFW |
| 6 | `fail2ban-setup.sh` | Enables the SSH jail on the effective port |
| 7 | `security-check-setup.sh` | Installs the daily report and root cron entry |
| 8 | `bbr-enable.sh` | Enables BBR persistently |

The basic deployment does not install Docker or RustDesk, run Speedtest/IP reputation tests, or disable ping.

After it finishes, keep the current session open and test a second connection before disconnecting:

```bash
ssh root@SERVER_IP -p 41337
```

## Debian administration packages

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/debian-admin-packages-install.sh | sudo bash
```

The script refreshes APT metadata and installs the following packages without upgrading the whole operating system:

| Package | Purpose |
|---|---|
| `sudo` | Controlled privilege escalation for non-root administrators |
| `ca-certificates` | HTTPS certificate verification |
| `curl` | HTTP downloads and API requests |
| `git` | Version-control workflows |
| `nano`, `less` | Editing and viewing text/logs |
| `cron` | Scheduled tasks |
| `ufw` | Host firewall |
| `fail2ban` | Brute-force protection |
| `unattended-upgrades`, `apt-listchanges` | Automatic updates and package change information |
| `lsof` | Open-file and socket diagnostics |
| `jq` | JSON processing |
| `dnsutils` | `dig`, `nslookup` and related DNS tools |
| `netcat-openbsd`, `socat` | TCP/UDP and socket diagnostics |
| `htop` | Interactive process viewer |
| `rsync` | File synchronization |

## Hostname change

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
```

The argument must start and end with a letter or digit and may contain letters, digits, dots and hyphens. The script updates or creates the `127.0.1.1` entry in `/etc/hosts`, then applies the hostname through `hostnamectl`.

Verify it with:

```bash
hostnamectl status
grep '^127.0.1.1' /etc/hosts
```

## Automatic APT security updates

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/apt-auto-upgrades.sh | sudo bash
```

The script installs `unattended-upgrades`, enables the `apt-daily` and `apt-daily-upgrade` timers, and writes:

| File | Configuration |
|---|---|
| `/etc/apt/apt.conf.d/20auto-upgrades` | Daily package-list refresh, daily unattended upgrades, weekly cache cleanup |
| `/etc/apt/apt.conf.d/52unattended-upgrades-local` | No automatic reboot; remove unused dependencies |

Inspect operation with:

```bash
systemctl list-timers 'apt-daily*' --no-pager
sudo less /var/log/unattended-upgrades/unattended-upgrades.log
```

## SSH port change

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

The port must be an integer from `1` to `65535`. The script performs the following sequence:

1. Creates a unique backup under `/etc/ssh/vps-toolkit-backups/`.
2. Ensures `/etc/ssh/sshd_config` includes `/etc/ssh/sshd_config.d/*.conf`.
3. Comments active `Port` directives in the main file and drop-ins.
4. Writes `/etc/ssh/sshd_config.d/99-vps-toolkit-port.conf`.
5. Runs `sshd -t` before applying anything; invalid configuration is restored automatically.
6. Adds a UFW `LIMIT` rule when UFW is installed.
7. Reloads the Debian `ssh` service without terminating the current session.
8. Restores the backup if reload fails.
9. Updates `/etc/fail2ban/jail.d/sshd.local` when present and restarts Fail2Ban.

The script intentionally does not remove old UFW rules. Remove them only after confirming a new login works.

```bash
sudo sshd -T | awk '$1 == "port"'
sudo ss -ltnp
sudo ufw status numbered
```

## Basic UFW firewall

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ufw-basic-setup.sh | sudo bash
```

It applies three operations:

```text
default deny incoming
default allow outgoing
enable UFW
```

This script does not guess or open the SSH port. Run it only after adding and testing the required SSH rule. The basic deployment performs these steps in the safe order.

## Fail2Ban SSH protection

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/fail2ban-setup.sh | sudo bash
```

The effective SSH port is read from `sshd -T` and written to `/etc/fail2ban/jail.d/sshd.local`.

| Setting | Value | Meaning |
|---|---:|---|
| `backend` | `systemd` | Read SSH events from the journal |
| `bantime` | `1h` | Ban duration |
| `findtime` | `10m` | Observation window |
| `maxretry` | `3` | Failures before a ban |

The configuration is validated before Fail2Ban is restarted. Verify it with:

```bash
sudo fail2ban-client status sshd
```

## Daily security report

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/security-check-setup.sh | sudo bash
```

The setup installs `/usr/local/bin/security-check.sh`, enables cron and adds a root job at `09:00`. The report contains:

- report timestamp and seven-day observation period;
- effective SSH port numbers;
- failed SSH authentication count from the journal;
- number of upgradable packages;
- Fail2Ban SSH jail status;
- listening and established SSH sockets.

The latest report replaces `/var/log/security-check.log` instead of growing the log indefinitely. The file is root-readable only (`0600`).

```bash
sudo /usr/local/bin/security-check.sh
sudo cat /var/log/security-check.log
sudo crontab -l
```

## BBR

Enable BBR:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/bbr-enable.sh | sudo bash
```

Disable BBR and use common Debian defaults:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/bbr-disable.sh | sudo bash
```

Both scripts manage `/etc/sysctl.d/99-bbr-vps-toolkit.conf` and apply only that file. Enable sets `fq` + `bbr`; disable sets `fq_codel` + `cubic`. Unsupported kernel settings fail explicitly instead of silently selecting an unrelated fallback.

```bash
sysctl net.core.default_qdisc net.ipv4.tcp_congestion_control
```

## Docker Engine and Compose

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/docker-debian-setup.sh | sudo bash
```

The script follows Docker's Debian APT-repository method:

1. Installs `ca-certificates` and `curl`.
2. Downloads Docker's signing key to `/etc/apt/keyrings/docker.asc`.
3. Writes `/etc/apt/sources.list.d/docker.sources` in Deb822 format.
4. Installs Docker Engine, CLI, containerd, Buildx and the Compose plugin.
5. Enables the Docker service and verifies the server version.

The Debian codename and `dpkg` architecture in the source file are required repository selectors, not platform-compatibility heuristics.

Docker-published ports can bypass UFW rules. Review [Docker's firewall warning](https://docs.docker.com/engine/install/debian/#firewall-limitations) and use the `DOCKER-USER` chain where filtering is required.

```bash
sudo systemctl status docker --no-pager
sudo docker version
sudo docker compose version
```

## RustDesk Server

Prerequisites: Docker Engine with the Compose plugin and UFW.

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/rustdesk-server-setup.sh | sudo bash
```

The script writes `/root/rustdeskdocker/docker-compose.yml`, starts `hbbs` and `hbbr` with host networking and persists keys/data under `/root/rustdeskdocker/data`.

| Port | Protocol | Purpose |
|---:|---|---|
| `21115` | TCP | NAT type test |
| `21116` | TCP/UDP | ID registration, heartbeat and hole punching |
| `21117` | TCP | Relay service |

These are the minimum RustDesk ports. WebSocket ports `21118` and `21119` are not opened. After startup, the script waits for and prints `data/id_ed25519.pub`, which must be configured in RustDesk clients.

### Why host networking instead of the official compose file

RustDesk's official compose file puts both containers on a bridge network and publishes the ports with a `ports:` mapping. That mapping is the case described in [Docker's firewall warning](https://docs.docker.com/engine/install/debian/#firewall-limitations) above: Docker writes its own iptables rules, published ports reach the containers regardless of UFW, and the `ufw allow` rules this script adds would be decorative — the ports would be open to the internet whether or not UFW permitted them.

With `network_mode: host` the containers bind directly on the host, no Docker port publishing happens, and UFW is genuinely the thing deciding who reaches `21115-21117`. The trade-off is that the containers share the host network namespace, so they get no network isolation and their ports cannot be remapped. For a single-purpose RustDesk host that is the better side of the trade; if you need isolation or remapped ports, use the official compose file and filter through the `DOCKER-USER` chain instead of UFW.

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

The script connects Ookla's Packagecloud repository, installs the official `speedtest` package and accepts the license/GDPR prompt for the initial test run.

## IP reputation check

This wrapper does not require root:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ip-quality-check.sh | bash
```

It downloads and runs the external IP.Check.Place checker in English with non-interactive options. Review that upstream service before using it on a sensitive host.

## Incoming ping

Disable incoming IPv4 and IPv6 echo requests:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ufw-disable-ping.sh | sudo bash
```

Restore them:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ufw-enable-ping.sh | sudo bash
```

The scripts modify only the echo-request rules in `/etc/ufw/before.rules` and `/etc/ufw/before6.rules`, verify the expected lines and reload UFW. Other ICMP/ICMPv6 traffic required for normal networking is not changed.

Blocking echo requests provides little hardening value and reduces observability, so it is optional and excluded from the basic deployment.

## Validation

Every push and pull request runs `.github/workflows/shellcheck.yml`, which checks all scripts with `bash -n` and ShellCheck.

The scripts are intended for Debian VPS hosts. They are not a generic cross-distribution provisioning framework and do not replace provider snapshots, tested backups or a configuration-management system.

## License

GPL-3.0-or-later — see [LICENSE](LICENSE).
