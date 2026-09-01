# VPS-toolkit

[Русский](README.ru.md)

Small, focused Bash scripts for initial Debian VPS setup, basic hardening, monitoring and self-hosted services.

## Requirements

- Debian with systemd
- root access
- `curl` for the one-line commands

Administrative scripts stop unless they run as root. `ip-quality-check.sh` is the only script that does not require elevated privileges.

## Scripts

| Script | Purpose |
|---|---|
| `apt-auto-upgrades.sh` | Configure unattended APT security updates |
| `bbr-enable.sh` / `bbr-disable.sh` | Enable or disable BBR persistently |
| `debian-admin-packages-install.sh` | Install a compact Debian admin package set |
| `docker-debian-setup.sh` | Install Docker Engine and Compose from Docker's repository |
| `fail2ban-setup.sh` | Protect the effective SSH port with Fail2Ban |
| `hostname-change.sh` | Change the hostname and update `/etc/hosts` |
| `ip-quality-check.sh` | Run the IP.Check.Place reputation check |
| `rustdesk-server-setup.sh` | Deploy RustDesk Server with Docker Compose |
| `security-check-setup.sh` | Install a daily SSH/security status report |
| `speedtest-cli.sh` | Install and run Ookla Speedtest CLI |
| `ssh-port-change.sh` | Change the SSH port and update UFW/Fail2Ban |
| `ufw-basic-setup.sh` | Set minimal UFW defaults and enable the firewall |
| `ufw-disable-ping.sh` / `ufw-enable-ping.sh` | Toggle incoming ICMP echo requests |
| `vps-basic-setup.sh` | Run the basic deployment sequence |

## Usage

Replace `SCRIPT_NAME.sh` with the required script:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Scripts with arguments:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

Run the IP reputation check without root:

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/ip-quality-check.sh | bash
```

## Basic VPS setup

```bash
curl -fsSL https://raw.githubusercontent.com/Plasmoid77/VPS-toolkit/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

The two arguments are the new hostname and SSH port. The script runs:

1. Debian admin packages
2. Hostname change
3. Automatic APT security updates
4. SSH port change and UFW limit rule
5. Basic UFW firewall
6. Fail2Ban for SSH
7. Daily security report
8. BBR

Keep the current SSH session open and verify a second login before disconnecting:

```bash
ssh root@SERVER_IP -p 41337
```

## Operational notes

- `ssh-port-change.sh` backs up SSH configuration under `/etc/ssh/vps-toolkit-backups/`, validates it before reload, and does not remove old UFW rules.
- Run `ufw-basic-setup.sh` only after allowing and testing the SSH port. The basic setup handles this order automatically.
- Disabling ping is optional and is not part of the basic setup; it provides little hardening value and makes diagnostics less useful.
- Docker-published container ports can bypass UFW rules. Review [Docker's firewall warning](https://docs.docker.com/engine/install/debian/#firewall-limitations) before exposing services.
- `rustdesk-server-setup.sh` requires Docker and UFW, stores data in `/root/rustdeskdocker`, and opens TCP `21115:21117` plus UDP `21116`.
- The daily report is written to `/var/log/security-check.log` at 09:00 and replaces the previous report to avoid unbounded log growth.

Inspect the generated security report manually:

```bash
sudo /usr/local/bin/security-check.sh
sudo cat /var/log/security-check.log
```
