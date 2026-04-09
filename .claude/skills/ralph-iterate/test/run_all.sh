#!/usr/bin/env bash
# Run all *_test.sh files in this directory.
# Usage: ./test/run_all.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
FAILED_SUITES=()

for t in "$HERE"/*_test.sh; do
  suite="$(basename "$t")"
  echo "═══ $suite ═══"
  if bash "$t"; then
    : # suite passed
  else
    FAILED_SUITES+=("$suite")
  fi
  echo
done

if [ ${#FAILED_SUITES[@]} -eq 0 ]; then
  echo "All suites passed."
else
  echo "FAILED suites: ${FAILED_SUITES[*]}"
  exit 1
fi
