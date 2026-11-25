#!/usr/bin/env bash
# Warn if any filesystem is above a usage threshold.
set -euo pipefail

THRESHOLD="${1:-80}"
status=0

while read -r usage mount; do
  pct="${usage%\%}"
  if [ "$pct" -ge "$THRESHOLD" ]; then
    echo "WARNING: $mount is at ${pct}% (threshold ${THRESHOLD}%)"
    status=1
  fi
done < <(df -P | awk 'NR>1 {print $5, $6}')

[ "$status" -eq 0 ] && echo "OK: all filesystems below ${THRESHOLD}%"
exit "$status"
