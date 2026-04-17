#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  echo ""
  echo "Interrupted. Exiting."
  exit 130
}
trap cleanup SIGINT SIGTERM

# --- Argument validation ---
if [[ $# -lt 2 ]]; then
  echo "Usage: ralph.sh <iterations> <issue>" >&2
  echo "  iterations  Positive integer — max loop iterations" >&2
  echo "  issue       GitHub issue number or full URL (e.g. 123 or https://github.com/owner/repo/issues/123)" >&2
  exit 1
fi

ITERATIONS="$1"
ISSUE_ARG="$2"

# Validate iterations is a positive integer
if ! [[ "$ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: iterations must be a positive integer, got '$ITERATIONS'" >&2
  exit 1
fi

# Extract issue number from URL or bare number
if [[ "$ISSUE_ARG" =~ ^https://github\.com/[^/]+/[^/]+/issues/([0-9]+)$ ]]; then
  ISSUE_NUMBER="${BASH_REMATCH[1]}"
elif [[ "$ISSUE_ARG" =~ ^[0-9]+$ ]]; then
  ISSUE_NUMBER="$ISSUE_ARG"
else
  echo "Error: issue must be a number or GitHub issue URL, got '$ISSUE_ARG'" >&2
  exit 1
fi

# --- Prerequisite checks ---
MISSING=()
for cmd in sbx gh git rsync; do
  if ! command -v "$cmd" &>/dev/null; then
    MISSING+=("$cmd")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Error: missing required tools: ${MISSING[*]}" >&2
  exit 1
fi

# --- Auto-detect repo ---
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || {
  echo "Error: could not detect GitHub repo. Are you in a git repo with a GitHub remote?" >&2
  exit 1
}

echo "ralph: iterations=$ITERATIONS issue=#$ISSUE_NUMBER repo=$REPO"

# --- Sync Claude config ---
sync_config() {
  mkdir -p .claude

  rsync -au ~/.claude/skills/ .claude/skills/
  rsync -au ~/.claude/settings.json .claude/settings.json
  rsync -au ~/.claude/statusline-command.sh .claude/statusline-command.sh

  # Warn if synced paths are not gitignored
  local paths=(".claude/skills/" ".claude/settings.json" ".claude/statusline-command.sh")
  for p in "${paths[@]}"; do
    if ! git check-ignore -q "$p" 2>/dev/null; then
      echo "Warning: '$p' is not in .gitignore — personal config may leak into the repo" >&2
    fi
  done
}

sync_config
echo "ralph: config synced"

# --- Sub-issue discovery and eligibility filter ---
# Returns: prints "NUMBER TITLE" of the next eligible slice
# Exit 0: found a slice; Exit 2: no eligible slices remain
find_next_slice() {
  local prd_number="$1"
  local repo="$2"

  # Fetch PRD body
  local body
  body=$(gh issue view "$prd_number" --repo "$repo" --json body -q .body 2>/dev/null) || {
    echo "Error: could not fetch PRD issue #$prd_number" >&2
    return 1
  }

  # Extract issue numbers from task list: "- [ ] #42" or "- [ ] #42 — title"
  # Also handles URLs like "- [ ] https://github.com/.../issues/42"
  local issue_numbers=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-\ \[\ \]\ \#([0-9]+) ]]; then
      issue_numbers+=("${BASH_REMATCH[1]}")
    elif [[ "$line" =~ ^[[:space:]]*-\ \[\ \]\ https://github\.com/[^/]+/[^/]+/issues/([0-9]+) ]]; then
      issue_numbers+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$body"

  if [[ ${#issue_numbers[@]} -eq 0 ]]; then
    echo "ralph: no task list items found in PRD #$prd_number" >&2
    return 2
  fi

  # Check each issue for eligibility: must be open and have no open PR
  for num in "${issue_numbers[@]}"; do
    # Check if issue is open
    local state
    state=$(gh issue view "$num" --repo "$repo" --json state -q .state 2>/dev/null) || continue
    if [[ "$state" != "OPEN" ]]; then
      continue
    fi

    # Check if there's already an open PR for this issue
    local pr_count
    pr_count=$(gh pr list --repo "$repo" --search "issue:$num" --state open --json number -q 'length' 2>/dev/null) || pr_count=0
    if [[ "$pr_count" -gt 0 ]]; then
      continue
    fi

    # Found an eligible slice — get its title
    local title
    title=$(gh issue view "$num" --repo "$repo" --json title -q .title 2>/dev/null) || title="unknown"
    echo "$num $title"
    return 0
  done

  echo "ralph: no eligible slices remain for PRD #$prd_number" >&2
  return 2
}

# --- Slugify a title for branch naming ---
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# --- Main loop ---
for (( i=1; i<=ITERATIONS; i++ )); do
  echo ""
  echo "ralph: === iteration $i/$ITERATIONS ==="

  git checkout main && git pull origin main

  # Find next eligible slice
  slice_info=$(find_next_slice "$ISSUE_NUMBER" "$REPO") || {
    rc=$?
    if [[ $rc -eq 2 ]]; then
      echo "ralph: all slices complete — exiting early"
      exit 0
    fi
    exit "$rc"
  }

  slice_number=$(echo "$slice_info" | cut -d' ' -f1)
  slice_title=$(echo "$slice_info" | cut -d' ' -f2-)
  slug=$(slugify "$slice_title")
  branch="issue-${slice_number}-${slug}"

  echo "ralph: picked #$slice_number — $slice_title"
  echo "ralph: branch=$branch"

  # Delete existing local branch if it exists (for retries)
  git branch -D "$branch" 2>/dev/null || true

  # Create fresh branch from main
  git checkout -b "$branch" main

  # Launch Claude in sandbox
  echo "ralph: launching sbx..."
  sbx run claude . -- -p "Implement GitHub issue #${slice_number}: ${slice_title}. Use /tdd. Commit when done."

done
