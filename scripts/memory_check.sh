#!/usr/bin/env bash
# Warn if memory usage is above a threshold (default 80%).
set -euo pipefail

THRESHOLD="${1:-80}"

read -r total used < <(free -m | awk '/^Mem:/ {print $2, $3}')
pct=$(( used * 100 / total ))

if [ "$pct" -ge "$THRESHOLD" ]; then
  echo "WARNING: memory at ${pct}% (threshold ${THRESHOLD}%)"
  exit 1
fi

echo "OK: memory at ${pct}% (threshold ${THRESHOLD}%)"
