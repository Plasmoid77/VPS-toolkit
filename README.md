````markdown
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
````

Example:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/fail2ban-setup.sh | sudo bash
```

## Hostname change

The hostname script requires an argument:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/hostname-change.sh | sudo bash -s -- ordinary-coffee
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

View the log:

```bash
sudo less /var/log/security-check.log
```

## Notes

These scripts are intended for Debian-based VPS servers.

Always review a script before running it:

```bash
curl -fsSL https://codeberg.org/Plasmoid28/VPS-toolkit/raw/branch/main/scripts/SCRIPT_NAME.sh | less
```

Use at your own risk.
