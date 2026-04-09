#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILURES=0

fail() {
  echo "FAIL: $1"
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "PASS: $1"
}

assert() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    pass "$desc"
  else
    fail "$desc"
  fi
}

README="$REPO_ROOT/README.md"

# --- Test: README documents init.sh as primary setup method ---
assert "README mentions scripts/init.sh" grep -q 'scripts/init.sh' "$README"

# --- Test: README documents update.sh for ongoing updates ---
assert "README mentions scripts/update.sh" grep -q 'scripts/update.sh' "$README"

# --- Test: old manual steps are removed ---
assert "README does not contain 'brew bundle' as a manual step" bash -c '! grep -q "^\$ brew bundle\|^brew bundle" "$1"' _ "$README"
assert "README does not contain 'stow .' as a manual step" bash -c '! grep -q "^\$ stow \.\|^stow \." "$1"' _ "$README"
assert "README does not contain 'rm -rf .git'" bash -c '! grep -q "rm -rf" "$1"' _ "$README"

echo
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
else
  echo "All tests passed"
fi
