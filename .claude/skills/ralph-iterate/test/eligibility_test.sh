#!/usr/bin/env bash
# Test runner for the eligibility module.
# Usage: ./test/run.sh        (runs all cases)
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=../eligibility.sh
. "$ROOT/eligibility.sh"

TMPDIR_T="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_T"' EXIT

# Build a fake `gh` script that prints whatever JSON we put in $RALPH_TEST_FIXTURE.
mkdir -p "$TMPDIR_T/bin"
cat > "$TMPDIR_T/bin/fake-gh" <<'SH'
#!/usr/bin/env bash
cat "$RALPH_TEST_FIXTURE"
SH
chmod +x "$TMPDIR_T/bin/fake-gh"
export GH="$TMPDIR_T/bin/fake-gh"

PASS=0
FAIL=0

# fixture <name> <json>     — write fixture file and export RALPH_TEST_FIXTURE
fixture() {
  local name="$1"
  local json="$2"
  local f="$TMPDIR_T/$name.json"
  printf '%s' "$json" > "$f"
  export RALPH_TEST_FIXTURE="$f"
}

# assert_eq <name> <expected> <actual>
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

# Helper: build a child issue body referencing PRD <p>, with optional Blocked by list.
# Args: <prd-ref> [blocker1 blocker2 ...]
make_body() {
  local prd_ref="$1"; shift
  local body="## Parent PRD\n\n#${prd_ref}\n\n## What to build\n\nstuff\n\n## Blocked by\n\n"
  if [ $# -eq 0 ]; then
    body="${body}None"
  else
    for b in "$@"; do
      body="${body}- Blocked by #${b}\n"
    done
  fi
  printf '%s' "$body"
}

# Helper: emit a JSON issue object
issue_json() {
  local num="$1" state="$2" body="$3"
  jq -n --argjson n "$num" --arg s "$state" --arg b "$(printf '%b' "$body")" \
    '{number: $n, state: $s, body: $b}'
}

# Helper: combine issue objects into a JSON array
issues_array() {
  printf '%s\n' "$@" | jq -s '.'
}

run() {
  echo "case: $1"
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. Empty child set → empty result
# ─────────────────────────────────────────────────────────────────────────────
run "empty child set returns empty"
fixture "empty" '[]'
out="$(eligibility 1)"
assert_eq "empty" "" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 2. One child, no blockers → returned
# ─────────────────────────────────────────────────────────────────────────────
run "one child no blockers"
i1="$(issue_json 1 OPEN "## Body")"
i2="$(issue_json 10 OPEN "$(make_body 1)")"
fixture "c2" "$(issues_array "$i1" "$i2")"
out="$(eligibility 1)"
assert_eq "one child no blockers" "10" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 3. One child, blocker still open → not returned
# ─────────────────────────────────────────────────────────────────────────────
run "blocker still open excluded"
i1="$(issue_json 1 OPEN "## Body")"
i_blk="$(issue_json 5 OPEN "## Body")"
i2="$(issue_json 10 OPEN "$(make_body 1 5)")"
fixture "c3" "$(issues_array "$i1" "$i_blk" "$i2")"
out="$(eligibility 1)"
assert_eq "blocker open excluded" "" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 4. One child, blocker closed → returned
# ─────────────────────────────────────────────────────────────────────────────
run "blocker closed included"
i1="$(issue_json 1 OPEN "## Body")"
i_blk="$(issue_json 5 CLOSED "## Body")"
i2="$(issue_json 10 OPEN "$(make_body 1 5)")"
fixture "c4" "$(issues_array "$i1" "$i_blk" "$i2")"
out="$(eligibility 1)"
assert_eq "blocker closed included" "10" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 5. Multiple eligible children → returned in ascending order
# ─────────────────────────────────────────────────────────────────────────────
run "multiple eligible ascending"
i1="$(issue_json 1 OPEN "## Body")"
ia="$(issue_json 30 OPEN "$(make_body 1)")"
ib="$(issue_json 12 OPEN "$(make_body 1)")"
ic="$(issue_json 21 OPEN "$(make_body 1)")"
fixture "c5" "$(issues_array "$i1" "$ia" "$ib" "$ic")"
out="$(eligibility 1)"
assert_eq "multiple eligible ascending" "$(printf '12\n21\n30')" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 6. Child with malformed Parent PRD reference (different PRD) → excluded
# ─────────────────────────────────────────────────────────────────────────────
run "different PRD excluded"
i1="$(issue_json 1 OPEN "## Body")"
ix="$(issue_json 99 OPEN "$(make_body 2)")"  # references PRD #2, not #1
fixture "c6" "$(issues_array "$i1" "$ix")"
out="$(eligibility 1)"
assert_eq "different PRD excluded" "" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 7. Child with multiple blockers, mixed open/closed → excluded
# ─────────────────────────────────────────────────────────────────────────────
run "mixed blockers excluded"
i1="$(issue_json 1 OPEN "## Body")"
i_a="$(issue_json 5 CLOSED "## Body")"
i_b="$(issue_json 6 OPEN "## Body")"
ix="$(issue_json 50 OPEN "$(make_body 1 5 6)")"
fixture "c7" "$(issues_array "$i1" "$i_a" "$i_b" "$ix")"
out="$(eligibility 1)"
assert_eq "mixed blockers excluded" "" "$out"

# ─────────────────────────────────────────────────────────────────────────────
# 8. Closed child → excluded regardless of blocker state
# ─────────────────────────────────────────────────────────────────────────────
run "closed child excluded"
i1="$(issue_json 1 OPEN "## Body")"
ix="$(issue_json 77 CLOSED "$(make_body 1)")"
fixture "c8" "$(issues_array "$i1" "$ix")"
out="$(eligibility 1)"
assert_eq "closed child excluded" "" "$out"

echo
echo "PASS=$PASS FAIL=$FAIL"
[ $FAIL -eq 0 ] || exit 1
