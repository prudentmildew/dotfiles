#!/usr/bin/env bash
# Test runner for the pr_creator module.
# Stubs git and gh to capture commands without side effects.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=../pr_creator.sh
. "$ROOT/pr_creator.sh"

PASS=0
FAIL=0
TMPDIR_T="$(mktemp -d)"
export TMPDIR_T
trap 'rm -rf "$TMPDIR_T"' EXIT

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

# Build a fake gh that records calls and returns fixture data.
# Each call appends args to $TMPDIR_T/gh_calls.log
# Behavior is switched based on the subcommand.
ISSUE_TITLE="Docker sandbox mode"
ISSUE_BODY="## Acceptance criteria

- [x] --docker flag is accepted
- [x] Without --docker, behavior is identical

## Blocked by

None"
ISSUE_LABELS='[{"name":"feature-step"},{"name":"enhancement"}]'

mkdir -p "$TMPDIR_T/bin"
cat > "$TMPDIR_T/bin/fake-gh" <<'SCRIPT'
#!/usr/bin/env bash
echo "$*" >> "$TMPDIR_T/gh_calls.log"
case "$1" in
  issue)
    case "$2" in
      view)
        if [[ "$*" == *"--json title"* ]]; then
          echo "$RALPH_TEST_ISSUE_TITLE"
        elif [[ "$*" == *"--json body"* ]]; then
          echo "$RALPH_TEST_ISSUE_BODY"
        elif [[ "$*" == *"--json labels"* ]]; then
          echo "$RALPH_TEST_ISSUE_LABELS"
        fi
        ;;
    esac
    ;;
  pr)
    case "$2" in
      create)
        echo "https://github.com/test/repo/pull/99"
        ;;
      edit)
        ;;
    esac
    ;;
esac
SCRIPT
chmod +x "$TMPDIR_T/bin/fake-gh"
export GH="$TMPDIR_T/bin/fake-gh"

# Build a fake git that records calls
cat > "$TMPDIR_T/bin/fake-git" <<'SCRIPT'
#!/usr/bin/env bash
echo "$*" >> "$TMPDIR_T/git_calls.log"
case "$1" in
  push) ;;
  log)
    echo "abc1234 First commit"
    echo "def5678 Second commit"
    ;;
esac
SCRIPT
chmod +x "$TMPDIR_T/bin/fake-git"
export GIT="$TMPDIR_T/bin/fake-git"

# Export test data for fake-gh
export RALPH_TEST_ISSUE_TITLE="$ISSUE_TITLE"
export RALPH_TEST_ISSUE_BODY="$ISSUE_BODY"
export RALPH_TEST_ISSUE_LABELS="$ISSUE_LABELS"

# ─────────────────────────────────────────────────────────────────────────────
# 1. create_pr pushes branch to origin
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr pushes branch"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
create_pr 42 main >/dev/null 2>&1
git_calls="$(cat "$TMPDIR_T/git_calls.log")"
assert_contains "git push" "push -u origin ralph/42" "$git_calls"

# ─────────────────────────────────────────────────────────────────────────────
# 2. create_pr creates PR with correct title format
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr title format"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
create_pr 42 main >/dev/null 2>&1
gh_calls="$(cat "$TMPDIR_T/gh_calls.log")"
assert_contains "pr title" "ralph: Docker sandbox mode (#42)" "$gh_calls"

# ─────────────────────────────────────────────────────────────────────────────
# 3. create_pr sets correct base and head
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr base and head"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
create_pr 42 main >/dev/null 2>&1
gh_calls="$(cat "$TMPDIR_T/gh_calls.log")"
assert_contains "pr base" "--base main" "$gh_calls"
assert_contains "pr head" "--head ralph/42" "$gh_calls"

# ─────────────────────────────────────────────────────────────────────────────
# 4. create_pr body includes Closes link
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr body has closes link"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
create_pr 42 main >/dev/null 2>&1
gh_calls="$(cat "$TMPDIR_T/gh_calls.log")"
assert_contains "closes link" "Closes #42" "$gh_calls"

# ─────────────────────────────────────────────────────────────────────────────
# 5. create_pr body includes acceptance criteria
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr body has acceptance criteria"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
create_pr 42 main >/dev/null 2>&1
gh_calls="$(cat "$TMPDIR_T/gh_calls.log")"
assert_contains "criteria" "--docker flag is accepted" "$gh_calls"

# ─────────────────────────────────────────────────────────────────────────────
# 6. create_pr body includes commit list
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr body has commits"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
create_pr 42 main >/dev/null 2>&1
gh_calls="$(cat "$TMPDIR_T/gh_calls.log")"
assert_contains "commit list" "abc1234" "$gh_calls"

# ─────────────────────────────────────────────────────────────────────────────
# 7. create_pr copies labels from issue
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr copies labels"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
create_pr 42 main >/dev/null 2>&1
gh_calls="$(cat "$TMPDIR_T/gh_calls.log")"
assert_contains "label feature-step" "feature-step" "$gh_calls"
assert_contains "label enhancement" "enhancement" "$gh_calls"

# ─────────────────────────────────────────────────────────────────────────────
# 8. create_pr returns PR URL
# ─────────────────────────────────────────────────────────────────────────────
run "create_pr returns URL"
> "$TMPDIR_T/gh_calls.log"
> "$TMPDIR_T/git_calls.log"
url="$(create_pr 42 main 2>/dev/null)"
assert_contains "pr url" "https://github.com/test/repo/pull/99" "$url"

echo
echo "PASS=$PASS FAIL=$FAIL"
[ $FAIL -eq 0 ] || exit 1
