#!/usr/bin/env bash
# Test runner for the docker_cmd module.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=../docker_cmd.sh
. "$ROOT/docker_cmd.sh"

PASS=0
FAIL=0

assert_eq() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $name"
    PASS=$((PASS+1))
  else
    echo "  FAIL: $name"
    echo "    expected: $(printf '%q' "$expected")"
    echo "    actual:   $(printf '%q' "$actual")"
    FAIL=$((FAIL+1))
  fi
}

assert_contains() {
  local name="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "  PASS: $name"
    PASS=$((PASS+1))
  else
    echo "  FAIL: $name"
    echo "    expected to contain: $(printf '%q' "$needle")"
    echo "    actual:              $(printf '%q' "$haystack")"
    FAIL=$((FAIL+1))
  fi
}

run() {
  echo "case: $1"
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. Without --docker: plain claude command
# ─────────────────────────────────────────────────────────────────────────────
run "no docker uses plain claude"
unset RALPH_CLAUDE_CMD 2>/dev/null || true
cmd="$(build_claude_cmd 0 0 "/repo" "-p '/ralph-iterate 1 2'")"
assert_eq "plain claude" "claude -p '/ralph-iterate 1 2'" "$cmd"

# ─────────────────────────────────────────────────────────────────────────────
# 2. With --docker: docker sandbox run claude with bind mounts
# ─────────────────────────────────────────────────────────────────────────────
run "docker mode uses docker sandbox"
unset RALPH_CLAUDE_CMD 2>/dev/null || true
cmd="$(build_claude_cmd 1 0 "/repo" "-p '/ralph-iterate 1 2'")"
assert_contains "docker sandbox" "docker sandbox run" "$cmd"
assert_contains "repo rw mount" "-v /repo:/repo" "$cmd"
assert_contains "gitconfig ro mount" ".gitconfig" "$cmd"
assert_contains "gh config ro mount" ".config/gh/" "$cmd"
assert_contains "claude config ro mount" ".claude/" "$cmd"
assert_contains "ro flag" ":ro" "$cmd"
assert_contains "prompt args" "-p '/ralph-iterate 1 2'" "$cmd"

# ─────────────────────────────────────────────────────────────────────────────
# 3. RALPH_CLAUDE_CMD overrides in non-docker mode
# ─────────────────────────────────────────────────────────────────────────────
run "RALPH_CLAUDE_CMD override without docker"
export RALPH_CLAUDE_CMD="my-custom-claude"
cmd="$(build_claude_cmd 0 0 "/repo" "-p '/ralph-iterate 1 2'")"
assert_eq "custom cmd" "my-custom-claude -p '/ralph-iterate 1 2'" "$cmd"
unset RALPH_CLAUDE_CMD

# ─────────────────────────────────────────────────────────────────────────────
# 4. RALPH_CLAUDE_CMD overrides in docker mode
# ─────────────────────────────────────────────────────────────────────────────
run "RALPH_CLAUDE_CMD override with docker"
export RALPH_CLAUDE_CMD="my-docker-cmd"
cmd="$(build_claude_cmd 1 0 "/repo" "-p '/ralph-iterate 1 2'")"
assert_eq "custom docker cmd" "my-docker-cmd -p '/ralph-iterate 1 2'" "$cmd"
unset RALPH_CLAUDE_CMD

# ─────────────────────────────────────────────────────────────────────────────
# 5. Docker bind mounts use correct read-only flags for credentials
# ─────────────────────────────────────────────────────────────────────────────
run "credential mounts are read-only"
unset RALPH_CLAUDE_CMD 2>/dev/null || true
cmd="$(build_claude_cmd 1 0 "/repo" "-p test")"
# Repo should NOT have :ro
assert_contains "repo no ro" "-v /repo:/repo " "$cmd"
# Credentials should have :ro
assert_contains "gitconfig ro" ".gitconfig:ro" "$cmd"
assert_contains "gh ro" ".config/gh/:ro" "$cmd"
assert_contains "claude ro" ".claude/:ro" "$cmd"

# ─────────────────────────────────────────────────────────────────────────────
# 6. --brave adds --dangerously-skip-permissions to plain claude
# ─────────────────────────────────────────────────────────────────────────────
run "brave mode plain claude"
unset RALPH_CLAUDE_CMD 2>/dev/null || true
cmd="$(build_claude_cmd 0 1 "/repo" "-p '/ralph-iterate 1 2'")"
assert_eq "brave plain" "claude --dangerously-skip-permissions -p '/ralph-iterate 1 2'" "$cmd"

# ─────────────────────────────────────────────────────────────────────────────
# 7. --brave adds --dangerously-skip-permissions to docker mode
# ─────────────────────────────────────────────────────────────────────────────
run "brave mode docker"
unset RALPH_CLAUDE_CMD 2>/dev/null || true
cmd="$(build_claude_cmd 1 1 "/repo" "-p '/ralph-iterate 1 2'")"
assert_contains "brave docker flag" "--dangerously-skip-permissions" "$cmd"
assert_contains "brave docker sandbox" "docker sandbox run" "$cmd"

# ─────────────────────────────────────────────────────────────────────────────
# 8. --brave adds flag even with RALPH_CLAUDE_CMD override
# ─────────────────────────────────────────────────────────────────────────────
run "brave mode with RALPH_CLAUDE_CMD"
export RALPH_CLAUDE_CMD="my-custom-claude"
cmd="$(build_claude_cmd 0 1 "/repo" "-p test")"
assert_eq "brave custom" "my-custom-claude --dangerously-skip-permissions -p test" "$cmd"
unset RALPH_CLAUDE_CMD

echo
echo "PASS=$PASS FAIL=$FAIL"
[ $FAIL -eq 0 ] || exit 1
