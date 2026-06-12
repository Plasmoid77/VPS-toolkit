# VPS-toolkit

A small collection of Bash scripts for quick VPS setup, basic hardening, monitoring and self-hosted services.

## Scripts

| Script | Purpose |
|---|---|
| `apt-auto-upgrades.sh` | Configure automatic APT security updates |
| `debian-admin-packages-install.sh` | Install an extended admin package set for Debian |
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

## Debian admin packages

Install an extended admin package set for a fresh Debian VPS:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/debian-admin-packages-install.sh | sudo bash
```

Package set:

| Package | Purpose |
|---|---|
| `sudo` | Run commands with elevated privileges |
| `curl` | Download scripts and make HTTP requests |
| `ca-certificates` | HTTPS certificate support |
| `gnupg` | GPG keys for external repositories |
| `git` | Git, Codeberg and GitHub workflows |
| `nano` | Simple terminal text editor |
| `less` | Log and text viewer |
| `cron` | Task scheduler |
| `ufw` | Firewall |
| `fail2ban` | SSH brute-force protection |
| `unattended-upgrades` | Automatic security updates |
| `apt-listchanges` | Package changelog viewer during upgrades |
| `lsof` | Open files and ports diagnostics |
| `jq` | JSON processor |
| `dnsutils` | DNS tools like `dig` and `nslookup` |
| `netcat-openbsd` | `nc` tool for port checks |
| `socat` | Advanced socket and network utility |
| `htop` | Interactive process viewer |
| `rsync` | File copy and sync tool |
| `fastfetch` | System information summary |
| `ranger` | Terminal file manager |

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

| Option | Meaning |
|---|---|
| `bantime = 3600` | Bans an IP for 1 hour |
| `findtime = 600` | Checks failed attempts within 10 minutes |
| `maxretry = 3` | Bans after 3 failed attempts |
| `port = auto` | Uses the current SSH port from `sshd`, for example `41337` |
| `backend = systemd` | Reads SSH logs through `journalctl` instead of `/var/log/auth.log` |

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

## Run scripts

```bash
# Install extended Debian admin package set
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/debian-admin-packages-install.sh | sudo bash

# Configure automatic APT security updates
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/apt-auto-upgrades.sh | sudo bash

# Install Docker Engine and Docker Compose plugin on Debian
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/docker-debian-setup.sh | sudo bash

# Install and configure Fail2Ban for SSH
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/fail2ban-setup.sh | sudo bash

# Change hostname and update /etc/hosts
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee

# Check IP address quality and reputation
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ip-quality-check.sh | sudo bash

# Deploy RustDesk Server with Docker Compose
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/rustdesk-server-setup.sh | sudo bash

# Install daily SSH/security monitoring script with logs
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/security-check-setup.sh | sudo bash

# Install and run Ookla Speedtest CLI
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/speedtest-cli.sh | sudo bash

# Disable incoming ping via UFW rules
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-disable-ping.sh | sudo bash

# Enable incoming ping back via UFW rules
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-enable-ping.sh | sudo bash
```
