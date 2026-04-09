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

# --- Test: init.sh exists and is executable ---
assert "scripts/init.sh exists" test -f "$REPO_ROOT/scripts/init.sh"
assert "scripts/init.sh is executable" test -x "$REPO_ROOT/scripts/init.sh"

# --- Test: init.sh runs commands in correct order with headers ---
SCRIPT="$REPO_ROOT/scripts/init.sh"

assert "prints brew bundle header" grep -q '==>.*[Bb]rew' "$SCRIPT"
assert "runs brew bundle" grep -q 'brew bundle' "$SCRIPT"
assert "prints stow header" grep -qE '==>.*([Ss]tow|symlink|dotfile)' "$SCRIPT"
assert "runs stow ." grep -q 'stow \.' "$SCRIPT"
assert "prints Claude Code header" grep -q '==>.*[Cc]laude' "$SCRIPT"
assert "runs native Claude Code installer" grep -q 'claude.ai/install.sh' "$SCRIPT"

# Verify ordering: brew bundle before stow, stow before claude installer
BREW_LINE=$(grep -n 'brew bundle' "$SCRIPT" | head -1 | cut -d: -f1)
STOW_LINE=$(grep -n 'stow \.' "$SCRIPT" | head -1 | cut -d: -f1)
CLAUDE_LINE=$(grep -n 'claude.ai/install.sh' "$SCRIPT" | head -1 | cut -d: -f1)
assert "brew bundle runs before stow" test "$BREW_LINE" -lt "$STOW_LINE"
assert "stow runs before claude installer" test "$STOW_LINE" -lt "$CLAUDE_LINE"

# --- Test: scripts is excluded from stow ---
assert "scripts listed in .stow-local-ignore" grep -q '^scripts$' "$REPO_ROOT/.stow-local-ignore"

# --- Test: stow doesn't symlink scripts/ into home ---
# Run stow in dry-run mode and verify scripts/ is not in the output
assert "stow dry-run does not symlink scripts/" bash -c '! stow -n -v . -d "$1" 2>&1 | grep -q "LINK: scripts"' _ "$REPO_ROOT"

echo
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
else
  echo "All tests passed"
fi
