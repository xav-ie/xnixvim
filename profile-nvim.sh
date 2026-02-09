#!/usr/bin/env bash

set -euo pipefail

LOGFILE=$(mktemp)
trap "rm -f $LOGFILE" EXIT

echo "Profiling Neovim startup..."
nvim --startuptime "$LOGFILE" +quit < /dev/null 2>/dev/null

echo ""
echo "=== SLOWEST REQUIRE() CALLS ==="
echo ""

awk 'NR > 1 && /require\(/ {
  time = $2
  msg = substr($0, index($0, $3))
  printf "%8s ms  %s\n", time, msg
}' "$LOGFILE" | sort -rn | head -15

echo ""
echo "=== SLOWEST PLUGIN LOADS ==="
echo ""

awk 'NR > 1 && /sourcing.*plugin/ {
  time = $2
  msg = substr($0, index($0, $3))
  printf "%8s ms  %s\n", time, msg
}' "$LOGFILE" | sort -rn | head -15

echo ""
echo "=== TOTAL STARTUP TIME ==="
TOTAL=$(grep 'NVIM STARTED' "$LOGFILE" | tail -1 | awk '{print $1}')
echo "${TOTAL} ms"
