# VPS-toolkit

[Русский](README.ru.md)

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
| `ssh-port-change.sh` | Change SSH port, add UFW limit rule and update Fail2Ban config |
| `ufw-basic-setup.sh` | Apply minimal UFW defaults and enable the firewall |
| `ufw-disable-ping.sh` | Disable incoming ping via UFW rules |
| `ufw-enable-ping.sh` | Enable incoming ping back via UFW rules |
| `vps-basic-setup.sh` | Run the full basic VPS deployment sequence |

## Usage

Replace `SCRIPT_NAME.sh` with the script you want to run:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/SCRIPT_NAME.sh | sudo bash
```

Example:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/fail2ban-setup.sh | sudo bash
```

## Quick basic VPS setup

The quick setup script runs the full basic deployment sequence for a new Debian VPS.

It takes two arguments:

| Argument | Meaning | Example |
|---|---|---|
| `NEW_HOSTNAME` | Desired server hostname | `ordinary-coffee` |
| `NEW_SSH_PORT` | Desired SSH port | `41337` |

Run:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337
```

What it runs:

| Order | Script | Action |
|---:|---|---|
| 1 | `debian-admin-packages-install.sh` | Installs the base Debian admin package set |
| 2 | `hostname-change.sh` | Changes hostname and updates `/etc/hosts` |
| 3 | `apt-auto-upgrades.sh` | Enables automatic APT security updates |
| 4 | `ssh-port-change.sh` | Changes SSH port and adds a UFW `LIMIT` rule |
| 5 | `ufw-basic-setup.sh` | Applies minimal UFW defaults and enables the firewall |
| 6 | `fail2ban-setup.sh` | Installs and configures Fail2Ban for SSH |
| 7 | `security-check-setup.sh` | Installs daily SSH/security monitoring |
| 8 | `bbr-enable.sh` | Enables BBR TCP congestion control |
| 9 | `ufw-disable-ping.sh` | Disables incoming ping |

This script is intended for a fast trusted initial setup when the base deployment flow is already known and tested. After it finishes, reconnect using the new SSH port.

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

## SSH port change

The SSH port script requires a port number as an argument:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337
```

What it does:

| Step | Action |
|---|---|
| Port validation | Checks that the argument is a valid port from `1` to `65535` |
| Backup | Saves SSH config backups under `/etc/ssh/vps-toolkit-backups/` |
| SSH config | Writes the new port to `/etc/ssh/sshd_config.d/99-vps-toolkit-port.conf` |
| Main config | Adds `Include /etc/ssh/sshd_config.d/*.conf` to `/etc/ssh/sshd_config` if missing |
| Old port lines | Comments active old `Port` lines in SSH config files |
| UFW | Adds a `LIMIT` rule for the new SSH port with the comment `SSH with basic brutforce protection` |
| Validation | Runs `sshd -t` before applying the change |
| Reload | Reloads SSH without closing the current session |
| Fail2Ban | Updates `/etc/fail2ban/jail.d/sshd.local` if it exists |

After running it, keep the current SSH session open and test a new login from another terminal:

```bash
ssh root@SERVER_IP -p 41337
```

The script does not remove old UFW rules automatically.

## Basic UFW setup

The basic UFW setup script applies minimal firewall defaults and enables UFW:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-basic-setup.sh | sudo bash
```

Run it only after SSH access has already been allowed, either by `ssh-port-change.sh` or manually:

| Requirement | Why it matters |
|---|---|
| `ssh-port-change.sh` has already been run, or the SSH port has been opened manually | This ensures UFW will not block SSH access after enabling the firewall |
| New SSH login has been tested from another terminal | This confirms that the SSH port is reachable |
| Required service ports are already allowed | Otherwise UFW may block services you need |

What it does:

| Step | Action |
|---|---|
| Incoming policy | Sets `sudo ufw default deny incoming` |
| Outgoing policy | Sets `sudo ufw default allow outgoing` |
| Enable firewall | Runs `sudo ufw --force enable` |
| Status check | Shows `sudo ufw status numbered` |

Do not run this script before the SSH port is allowed and tested, otherwise you can lock yourself out of the server.

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

## Run scripts

```bash
# Run the full basic VPS deployment sequence
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/vps-basic-setup.sh | sudo bash -s -- ordinary-coffee 41337

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

# Change SSH port, add UFW limit rule and update Fail2Ban config
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ssh-port-change.sh | sudo bash -s -- 41337

# Apply minimal UFW defaults and enable the firewall
# Run only after ssh-port-change.sh or after manually opening and testing the SSH port
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-basic-setup.sh | sudo bash

# Disable incoming ping via UFW rules
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-disable-ping.sh | sudo bash

# Enable incoming ping back via UFW rules
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/ufw-enable-ping.sh | sudo bash
```

## Notes

These scripts are intended for Debian-based VPS servers.
