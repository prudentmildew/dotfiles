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
