#!/usr/bin/env bash
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run this script as root." >&2; exit 1; }

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
    sudo \
    ca-certificates \
    curl \
    git \
    nano \
    less \
    cron \
    ufw \
    fail2ban \
    unattended-upgrades \
    apt-listchanges \
    lsof \
    jq \
    dnsutils \
    netcat-openbsd \
    socat \
    htop \
    rsync

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' Debian admin packages installed successfully.' \
    '============================================================'
