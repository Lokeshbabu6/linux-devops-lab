#!/usr/bin/env bash
# Check whether one or more systemd services are active.
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <service> [service...]" >&2
  exit 2
fi

failed=0
for svc in "$@"; do
  if systemctl is-active --quiet "$svc"; then
    echo "OK: $svc is running"
  else
    echo "FAIL: $svc is not running"
    failed=1
  fi
done
exit "$failed"
