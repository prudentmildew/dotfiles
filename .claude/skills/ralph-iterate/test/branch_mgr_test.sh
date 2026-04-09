#!/usr/bin/env bash
# Test runner for the branch_mgr module.
# Uses a real temporary git repo for integration-style tests.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=../branch_mgr.sh
. "$ROOT/branch_mgr.sh"

PASS=0
FAIL=0
TMPDIR_T="$(mktemp -d)"
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

run() {
  echo "case: $1"
}

# Set up a fresh git repo for each test
setup_repo() {
  local repo="$TMPDIR_T/repo-$RANDOM"
  mkdir -p "$repo"
  cd "$repo"
  git init -q
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "initial" > file.txt
  git add file.txt
  git commit -q -m "initial commit"
  echo "$repo"
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. ensure_branch creates new branch from base
# ─────────────────────────────────────────────────────────────────────────────
run "ensure_branch creates new branch"
repo="$(setup_repo)"
cd "$repo"
base="$(git rev-parse --abbrev-ref HEAD)"
branch="$(ensure_branch 42 "$base")"
assert_eq "branch name" "ralph/42" "$branch"
current="$(git rev-parse --abbrev-ref HEAD)"
assert_eq "on branch" "ralph/42" "$current"

# ─────────────────────────────────────────────────────────────────────────────
# 2. ensure_branch reuses existing branch
# ─────────────────────────────────────────────────────────────────────────────
run "ensure_branch reuses existing branch"
repo="$(setup_repo)"
cd "$repo"
base="$(git rev-parse --abbrev-ref HEAD)"
# Create branch, add a commit, go back to base
git checkout -q -b ralph/42
echo "progress" >> file.txt
git add file.txt
git commit -q -m "partial progress"
progress_sha="$(git rev-parse HEAD)"
git checkout -q "$base"
# Now ensure_branch should reuse
branch="$(ensure_branch 42 "$base")"
assert_eq "reuse branch name" "ralph/42" "$branch"
current_sha="$(git rev-parse HEAD)"
assert_eq "reuse preserves commit" "$progress_sha" "$current_sha"

# ─────────────────────────────────────────────────────────────────────────────
# 3. return_to_base switches to base branch
# ─────────────────────────────────────────────────────────────────────────────
run "return_to_base switches back"
repo="$(setup_repo)"
cd "$repo"
base="$(git rev-parse --abbrev-ref HEAD)"
git checkout -q -b ralph/42
return_to_base "$base"
current="$(git rev-parse --abbrev-ref HEAD)"
assert_eq "back to base" "$base" "$current"

# ─────────────────────────────────────────────────────────────────────────────
# 4. cleanup_empty_branch deletes branch with no new commits
# ─────────────────────────────────────────────────────────────────────────────
run "cleanup_empty_branch deletes empty"
repo="$(setup_repo)"
cd "$repo"
base="$(git rev-parse --abbrev-ref HEAD)"
head_before="$(git rev-parse HEAD)"
git checkout -q -b ralph/42
git checkout -q "$base"
cleanup_empty_branch 42 "$base" "$head_before"
rc=$?
assert_eq "cleanup returns 0" "0" "$rc"
# Branch should be gone
exists="$(git branch --list ralph/42)"
assert_eq "branch deleted" "" "$exists"

# ─────────────────────────────────────────────────────────────────────────────
# 5. cleanup_empty_branch preserves branch with commits
# ─────────────────────────────────────────────────────────────────────────────
run "cleanup_empty_branch preserves branch with commits"
repo="$(setup_repo)"
cd "$repo"
base="$(git rev-parse --abbrev-ref HEAD)"
head_before="$(git rev-parse HEAD)"
git checkout -q -b ralph/42
echo "new work" >> file.txt
git add file.txt
git commit -q -m "new work"
git checkout -q "$base"
cleanup_empty_branch 42 "$base" "$head_before"
rc=$?
assert_eq "cleanup returns 1" "1" "$rc"
exists="$(git branch --list ralph/42 | tr -d ' ')"
assert_eq "branch preserved" "ralph/42" "$exists"

# ─────────────────────────────────────────────────────────────────────────────
# 6. ensure_branch new branch starts from base_branch HEAD
# ─────────────────────────────────────────────────────────────────────────────
run "new branch starts from base HEAD"
repo="$(setup_repo)"
cd "$repo"
base="$(git rev-parse --abbrev-ref HEAD)"
base_sha="$(git rev-parse HEAD)"
ensure_branch 42 "$base" >/dev/null
branch_base="$(git merge-base HEAD "$base")"
assert_eq "branch base matches" "$base_sha" "$branch_base"

echo
echo "PASS=$PASS FAIL=$FAIL"
[ $FAIL -eq 0 ] || exit 1
