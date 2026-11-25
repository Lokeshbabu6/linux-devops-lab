#!/usr/bin/env bash
# Print a quick system summary.
set -euo pipefail

echo "Host:    $(hostname)"
echo "Kernel:  $(uname -r)"
echo "Uptime:  $(uptime -p)"
echo "Load:    $(cut -d' ' -f1-3 /proc/loadavg)"
