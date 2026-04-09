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

# --- Test: update.sh exists and is executable ---
assert "scripts/update.sh exists" test -f "$REPO_ROOT/scripts/update.sh"
assert "scripts/update.sh is executable" test -x "$REPO_ROOT/scripts/update.sh"

# --- Test: uses strict mode and changes to repo root ---
SCRIPT="$REPO_ROOT/scripts/update.sh"
assert "uses set -euo pipefail" grep -q 'set -euo pipefail' "$SCRIPT"
assert "changes to repo root" grep -q 'cd.*dirname' "$SCRIPT"

# --- Test: update.sh runs commands in correct order with headers ---
assert "prints brew update header" grep -qE '==>.*[Uu]pdat' "$SCRIPT"
assert "runs brew update && brew upgrade" grep -q 'brew update && brew upgrade' "$SCRIPT"
assert "prints brew bundle header" grep -qE '==>.*[Bb]rew.*(bundle|Brewfile|pack)' "$SCRIPT"
assert "runs brew bundle" grep -q 'brew bundle' "$SCRIPT"
assert "prints stow header" grep -qE '==>.*([Ss]tow|symlink|dotfile)' "$SCRIPT"
assert "runs stow ." grep -q 'stow \.' "$SCRIPT"
assert "prints Claude Code header" grep -q '==>.*[Cc]laude' "$SCRIPT"
assert "runs native Claude Code installer" grep -q 'claude.ai/install.sh' "$SCRIPT"

# Verify ordering: brew update before brew bundle, brew bundle before stow, stow before claude installer
BREW_UPDATE_LINE=$(grep -n 'brew update && brew upgrade' "$SCRIPT" | head -1 | cut -d: -f1)
BREW_BUNDLE_LINE=$(grep -n 'brew bundle' "$SCRIPT" | head -1 | cut -d: -f1)
STOW_LINE=$(grep -n 'stow \.' "$SCRIPT" | head -1 | cut -d: -f1)
CLAUDE_LINE=$(grep -n 'claude.ai/install.sh' "$SCRIPT" | head -1 | cut -d: -f1)
assert "brew update runs before brew bundle" test "$BREW_UPDATE_LINE" -lt "$BREW_BUNDLE_LINE"
assert "brew bundle runs before stow" test "$BREW_BUNDLE_LINE" -lt "$STOW_LINE"
assert "stow runs before claude installer" test "$STOW_LINE" -lt "$CLAUDE_LINE"

echo
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
else
  echo "All tests passed"
fi
