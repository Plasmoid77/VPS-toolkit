#!/usr/bin/env bash
set -euo pipefail

# Runs an unpinned third-party script (curl | bash, no checksum). See the
# README warning: review the upstream service before using it on a sensitive host.
curl -fsSL https://IP.Check.Place | bash -s -- -l en -p -y

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' IP quality check completed successfully.' \
    '============================================================'
