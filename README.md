# VPS-toolkit

A small collection of Bash scripts for quick VPS setup, basic hardening, monitoring and self-hosted services.

## Scripts

| Script | Purpose |
|---|---|
| `apt-auto-upgrades.sh` | Configure automatic APT security updates |
| `docker-debian-setup.sh` | Install Docker Engine and Docker Compose plugin on Debian |
| `fail2ban-setup.sh` | Install and configure Fail2Ban for SSH |
| `hostname-change.sh` | Change system hostname and update `/etc/hosts` |
| `ip-quality-check.sh` | Check IP address quality and reputation |
| `rustdesk-server-setup.sh` | Deploy RustDesk Server with Docker Compose |
| `security-check-setup.sh` | Install daily SSH/security monitoring script with logs |
| `speedtest-cli.sh` | Install and run Ookla Speedtest CLI |
| `ufw-disable-ping.sh` | Disable incoming ping via UFW rules |
| `ufw-enable-ping.sh` | Enable incoming ping back via UFW rules |

## Usage

Replace `SCRIPT_NAME.sh` with the script you want to run:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Example:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/fail2ban-setup.sh | sudo bash
```

## Hostname change

The hostname script requires an argument:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
```

## Fail2Ban

Check the generated SSH jail config:

```bash
sudo cat /etc/fail2ban/jail.d/sshd.local
```

Configuration meaning:

```text
bantime = 3600       # bans an IP for 1 hour
findtime = 600       # checks failed attempts within 10 minutes
maxretry = 3         # bans after 3 failed attempts
port = auto          # uses the current SSH port from sshd, for example 41337
backend = systemd    # reads SSH logs through journalctl instead of /var/log/auth.log
```

## APT auto-upgrades

View unattended-upgrades log:

```bash
sudo less /var/log/unattended-upgrades/unattended-upgrades.log
```

Exit log view:

```text
q
```

## Security check

Install daily monitoring:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/security-check-setup.sh | sudo bash
```

Run the installed check manually:

```bash
sudo /usr/local/bin/security-check.sh
```

Run the installed check manually and write output to the log:

```bash
sudo /usr/local/bin/security-check.sh >> /var/log/security-check.log 2>&1
sudo tail -n 100 /var/log/security-check.log
```

View the log:

```bash
sudo less /var/log/security-check.log
```

## RustDesk Server

The RustDesk setup script opens only the minimum required ports.

If web client support is needed, add these UFW rules:

```bash
sudo ufw allow 21118/tcp   # RustDesk web client support for hbbs
sudo ufw allow 21119/tcp   # RustDesk web client support for hbbr
```

## Notes

These scripts are intended for Debian-based VPS servers.
