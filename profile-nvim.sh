#!/usr/bin/env bash

# Profile Neovim startup.
#
# Ranks by SELF time, not cumulative. `--startuptime` prints three numbers per
# line: clock, self+sourced, self. Ranking on self+sourced (field 2) makes
# parent modules dominate the list and counts every child twice -- a tree like
# require('codediff.ui') -> require('codediff.ui.view') -> ... reports the same
# milliseconds at every level. Self time (field 3) is what you can actually act
# on, and it sums to the real total.
#
# Startup time is noisy, so this takes the median of several runs rather than
# trusting a single one (the first run is always slow from cold page cache).
#
# PERCEIVED startup is a different number from the one below. `--startuptime
# +quit` measures time-to-exit with no UI attached, which both skips rendering
# and forces deferred work (anything hung off DeferredUIEnter) to run before
# the timer stops. What you actually feel is time-to-first-paint, and for
# opening a file it is dominated by the FileType handler chain, which
# --startuptime never sees.
#
# Pass a file to measure that instead: it opens the file under a real pty with
# a forced redraw and reports the wall clock, plus the same for an empty
# buffer so you can subtract the pty overhead.
#
# Usage:
#   ./profile-nvim.sh                      # profile `nvim` from PATH
#   NVIM=./result/bin/nvim ./profile-nvim.sh   # profile a specific build
#   RUNS=20 ./profile-nvim.sh              # more samples
#   ./profile-nvim.sh README.md            # perceived cost of opening a file

set -euo pipefail

NVIM=${NVIM:-nvim}
RUNS=${RUNS:-10}
TOP=${TOP:-20}
TARGET=${1:-}

if ! command -v "$NVIM" >/dev/null 2>&1 && [ ! -x "$NVIM" ]; then
  echo "error: '$NVIM' not found (set NVIM=/path/to/nvim)" >&2
  exit 1
fi

TMPDIR_RUN=$(mktemp -d)
trap 'rm -rf "$TMPDIR_RUN"' EXIT

echo "Profiling: $NVIM"
echo "Runs:      $RUNS"
echo ""

# --- perceived mode: time to open and paint a real file ------------------
if [ -n "$TARGET" ]; then
  if [ ! -r "$TARGET" ]; then
    echo "error: cannot read '$TARGET'" >&2
    exit 1
  fi

  # `script` gives nvim a pty so the TUI actually renders; -c redraw forces a
  # paint before quitting. The empty-buffer run is the baseline to subtract --
  # most of the absolute number is pty setup, not nvim.
  paint() {
    local total=0 n=5
    for _ in $(seq 1 $n); do
      local s e
      s=$(date +%s%N)
      TERM=xterm-256color script -qfc \
        "TERM=xterm-256color $NVIM -c 'redraw' -c 'qa!' $1" /dev/null >/dev/null 2>&1
      e=$(date +%s%N)
      total=$(( total + (e - s) / 1000000 ))
    done
    echo $(( total / n ))
  }

  : > "$TMPDIR_RUN/empty"
  base=$(paint "$TMPDIR_RUN/empty")
  file=$(paint "$TARGET")

  echo "=== PERCEIVED OPEN COST (mean of 5, ms) ==="
  echo ""
  printf "%8d  empty buffer (pty + startup baseline)\n" "$base"
  printf "%8d  %s\n" "$file" "$TARGET"
  printf "%8d  <- attributable to opening this file\n" "$(( file - base ))"
  echo ""
  echo "If that delta is large, it is the FileType handler chain, not startup."
  echo "Bisect it by dropping autocmd groups, e.g. lz_n_handler_event (lazy"
  echo "plugin loads) or syntaxset (legacy vim syntax), and re-measuring."
  exit 0
fi

for i in $(seq 1 "$RUNS"); do
  "$NVIM" --startuptime "$TMPDIR_RUN/run$i.log" +quit </dev/null >/dev/null 2>&1
done

# Collect totals, pair each with its log so we can break down the median run.
for i in $(seq 1 "$RUNS"); do
  t=$(grep 'NVIM STARTED' "$TMPDIR_RUN/run$i.log" | tail -1 | awk '{print $1}')
  echo "$t $TMPDIR_RUN/run$i.log"
done | sort -n > "$TMPDIR_RUN/totals"

echo "=== TOTAL STARTUP (ms) ==="
awk '{print $1}' "$TMPDIR_RUN/totals" | tr '\n' ' '
echo ""
awk '{a[NR]=$1} END {
  printf "min %.1f   median %.1f   max %.1f\n", a[1], a[int((NR+1)/2)], a[NR]
}' "$TMPDIR_RUN/totals"

# Break down the median run, not the fastest or slowest.
MEDIAN_LOG=$(awk '{a[NR]=$2} END {print a[int((NR+1)/2)]}' "$TMPDIR_RUN/totals")

echo ""
echo "=== SLOWEST BY SELF TIME (ms) ==="
echo ""
awk '
  $3 ~ /:$/ {
    self = $3; sub(/:$/, "", self)
    msg = substr($0, index($0, $4))
    printf "%8.3f  %s\n", self, msg
  }
' "$MEDIAN_LOG" | sort -rn | awk -v n="$TOP" 'NR<=n'

echo ""
echo "=== SELF TIME BY LUA MODULE (ms) ==="
echo ""
awk '
  $3 ~ /:$/ && /require\(/ {
    self = $3; sub(/:$/, "", self)
    # pull the top-level namespace out of require('"'"'a.b.c'"'"')
    line = $0
    if (match(line, /require\(.[^.)]*/)) {
      mod = substr(line, RSTART + 9, RLENGTH - 9)
      gsub(/[^A-Za-z0-9_-]/, "", mod)
      if (mod != "") { total[mod] += self; count[mod]++ }
    }
  }
  END {
    for (m in total) printf "%8.3f  %3d modules  %s\n", total[m], count[m], m
  }
' "$MEDIAN_LOG" | sort -rn | awk -v n="$TOP" 'NR<=n'

echo ""
echo "=== SUMMARY ==="
echo ""
awk '
  $3 ~ /:$/ {
    self = $3; sub(/:$/, "", self)
    if ($0 ~ /require\(/) { req += self; reqn++ }
    else if ($0 ~ /sourcing/) {
      src += self; srcn++
      if ($0 ~ /init\.lua/) init += self
    }
  }
  END {
    printf "%8.1f ms  %4d require() calls\n", req, reqn
    printf "%8.1f ms  %4d sourced files\n", src, srcn
    printf "%8.1f ms  generated init.lua (your config body)\n", init
  }
' "$MEDIAN_LOG"
