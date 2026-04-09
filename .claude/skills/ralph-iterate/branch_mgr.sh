#!/usr/bin/env bash
# branch_mgr.sh — deep module: per-issue branch lifecycle management.
#
# Provides: ensure_branch(), return_to_base(), cleanup_empty_branch()
# All git operations use plain git (testable via real temp repos).

# ensure_branch <issue_number> <base_branch>
# Creates ralph/<N> from base_branch if new, checks out if existing.
# Prints the branch name to stdout.
ensure_branch() {
  local issue="$1" base="$2"
  local branch="ralph/${issue}"
  if git rev-parse --verify "$branch" >/dev/null 2>&1; then
    git checkout -q "$branch"
  else
    git checkout -q -b "$branch" "$base"
  fi
  echo "$branch"
}

# return_to_base <base_branch>
# Switches back to the base branch.
return_to_base() {
  local base="$1"
  git checkout -q "$base"
}

# cleanup_empty_branch <issue_number> <base_branch> <head_before>
# If no new commits were added (branch tip == head_before), delete the branch.
# Returns 0 if cleaned up, 1 if branch had commits and was preserved.
cleanup_empty_branch() {
  local issue="$1" base="$2" head_before="$3"
  local branch="ralph/${issue}"
  local branch_tip
  branch_tip="$(git rev-parse "$branch" 2>/dev/null || echo "")"
  if [ -z "$branch_tip" ]; then
    return 0
  fi
  if [ "$branch_tip" = "$head_before" ]; then
    git branch -D "$branch" >/dev/null 2>&1
    return 0
  fi
  return 1
}
