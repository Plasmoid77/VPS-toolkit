#!/usr/bin/env bash
set -euo pipefail

curl -fsSL https://IP.Check.Place | bash -s -- -l en -p -y

printf '\n\033[1;32m%s\n%s\n%s\033[0m\n' \
    '============================================================' \
    ' IP quality check completed successfully.' \
    '============================================================'
