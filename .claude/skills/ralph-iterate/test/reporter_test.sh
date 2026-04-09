#!/usr/bin/env bash
# Test runner for the reporter module.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=../reporter.sh
. "$ROOT/reporter.sh"

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
# 1. Banner displays iteration number and max iterations
# ─────────────────────────────────────────────────────────────────────────────
run "banner shows iter and max"
out="$(banner 1 10 42 "Docker sandbox" "ralph/42" 5 2 2>&1)"
assert_contains "banner iter" "1/10" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 2. Banner displays issue number and title
# ─────────────────────────────────────────────────────────────────────────────
run "banner shows issue and title"
out="$(banner 1 10 42 "Docker sandbox" "ralph/42" 5 2 2>&1)"
assert_contains "banner issue" "#42" "$out"
assert_contains "banner title" "Docker sandbox" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 3. Banner displays branch name
# ─────────────────────────────────────────────────────────────────────────────
run "banner shows branch"
out="$(banner 1 10 42 "Docker sandbox" "ralph/42" 5 2 2>&1)"
assert_contains "banner branch" "ralph/42" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 4. Banner displays open and closed counts
# ─────────────────────────────────────────────────────────────────────────────
run "banner shows counts"
out="$(banner 1 10 42 "Docker sandbox" "ralph/42" 5 2 2>&1)"
assert_contains "banner open" "open: 5" "$out"
assert_contains "banner closed" "closed: 2" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 5. Banner shows "current" when no branch name provided
# ─────────────────────────────────────────────────────────────────────────────
run "banner shows current for empty branch"
out="$(banner 1 10 42 "Docker sandbox" "" 5 2 2>&1)"
assert_contains "banner current" "current" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 6. Outcome line shows iteration, outcome, and duration
# ─────────────────────────────────────────────────────────────────────────────
run "outcome_line content"
RALPH_RESULTS=()
out="$(outcome_line 1 42 "closed" 45 2>&1)"
assert_contains "outcome iter" "iter 1" "$out"
assert_contains "outcome result" "closed" "$out"
assert_contains "outcome duration" "45s" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 7. Outcome line stores result in RALPH_RESULTS
# ─────────────────────────────────────────────────────────────────────────────
run "outcome_line stores result"
RALPH_RESULTS=()
outcome_line 1 42 "closed" 45 "PR #99" 2>/dev/null
outcome_line 2 43 "partial" 30 2>/dev/null
assert_eq "results count" "2" "${#RALPH_RESULTS[@]}"

# ─────────────────────────────────────────────────────────────────────────────
# 8. Summary table includes all stored results
# ─────────────────────────────────────────────────────────────────────────────
run "summary_table includes results"
RALPH_RESULTS=()
outcome_line 1 42 "closed" 45 "PR #99" 2>/dev/null
outcome_line 2 43 "partial" 30 2>/dev/null
out="$(summary_table 2>&1)"
assert_contains "table has issue 42" "#42" "$out"
assert_contains "table has issue 43" "#43" "$out"
assert_contains "table has closed" "closed" "$out"
assert_contains "table has partial" "partial" "$out"
assert_contains "table has PR note" "PR #99" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 9. Summary table handles empty results
# ─────────────────────────────────────────────────────────────────────────────
run "summary_table empty"
RALPH_RESULTS=()
out="$(summary_table 2>&1)"
assert_contains "empty table msg" "No iterations" "$out"

echo
echo "PASS=$PASS FAIL=$FAIL"
[ $FAIL -eq 0 ] || exit 1
